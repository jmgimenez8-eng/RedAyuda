import { getPaypalAccessToken, PAYPAL_BASE_URL } from "../_shared/paypal.ts";
import {
  CORS_HEADERS,
  getCallingUserClient,
  getSupabaseAdmin,
} from "../_shared/supabaseAdmin.ts";

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    const { pagoId } = await req.json();
    if (!pagoId) {
      return json({ error: "pagoId is required" }, 400);
    }

    const userClient = getCallingUserClient(authHeader);
    const { data: { user }, error: userError } = await userClient.auth.getUser();
    if (userError || !user) {
      return json({ error: "Not authenticated" }, 401);
    }

    const admin = getSupabaseAdmin();

    const { data: pago, error: pagoError } = await admin
      .from("pagos")
      .select("id, solicitante_id, paypal_order_id, estado")
      .eq("id", pagoId)
      .single();

    if (pagoError || !pago) {
      return json({ error: "Pago not found" }, 404);
    }

    if (pago.solicitante_id !== user.id) {
      return json({ error: "Forbidden" }, 403);
    }

    if (!pago.paypal_order_id) {
      return json({ error: "No PayPal order associated with this pago" }, 409);
    }

    const accessToken = await getPaypalAccessToken();

    const captureRes = await fetch(
      `${PAYPAL_BASE_URL}/v2/checkout/orders/${pago.paypal_order_id}/capture`,
      {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
      },
    );

    const captureJson = await captureRes.json();

    // 422 ORDER_ALREADY_CAPTURED se trata como éxito idempotente (reintento tras un timeout, etc.)
    const alreadyCaptured = captureJson?.details?.[0]?.issue === "ORDER_ALREADY_CAPTURED";
    if (!captureRes.ok && !alreadyCaptured) {
      return json({ error: "PayPal capture failed", details: captureJson }, 502);
    }

    const status = captureJson.status;
    const captureId =
      captureJson.purchase_units?.[0]?.payments?.captures?.[0]?.id ?? null;

    if (status !== "COMPLETED" || !captureId) {
      return json(
        { error: `Unexpected capture status: ${status}`, details: captureJson },
        502,
      );
    }

    const { data: updated, error: updateError } = await admin
      .from("pagos")
      .update({
        paypal_capture_id: captureId,
        estado: "retenido",
      })
      .eq("id", pago.id)
      .select()
      .single();

    if (updateError) {
      return json({ error: updateError.message }, 500);
    }

    return json({ pago: updated });
  } catch (err) {
    return json({ error: String(err) }, 500);
  }
});
