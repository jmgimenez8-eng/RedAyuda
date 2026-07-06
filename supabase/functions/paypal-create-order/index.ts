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

    // Verifica que el llamante está autenticado.
    const userClient = getCallingUserClient(authHeader);
    const { data: { user }, error: userError } = await userClient.auth.getUser();
    if (userError || !user) {
      return json({ error: "Not authenticated" }, 401);
    }

    const admin = getSupabaseAdmin();

    // El importe se toma siempre de la BD, nunca del cliente.
    const { data: pago, error: pagoError } = await admin
      .from("pagos")
      .select("id, importe, estado, solicitante_id")
      .eq("id", pagoId)
      .single();

    if (pagoError || !pago) {
      return json({ error: "Pago not found" }, 404);
    }

    if (pago.solicitante_id !== user.id) {
      return json({ error: "Forbidden" }, 403);
    }

    if (pago.estado !== "retenido") {
      return json(
        { error: `Pago is in state '${pago.estado}', cannot create order` },
        409,
      );
    }

    const accessToken = await getPaypalAccessToken();

    const orderRes = await fetch(`${PAYPAL_BASE_URL}/v2/checkout/orders`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        intent: "CAPTURE",
        purchase_units: [
          {
            reference_id: pago.id,
            amount: {
              currency_code: "EUR",
              value: Number(pago.importe).toFixed(2),
            },
            description: "Pago en garantía REDAYUDA",
          },
        ],
        application_context: {
          brand_name: "RedAyuda",
          user_action: "PAY_NOW",
          return_url: "https://redayuda.app/paypal-return",
          cancel_url: "https://redayuda.app/paypal-cancel",
        },
      }),
    });

    const orderJson = await orderRes.json();
    if (!orderRes.ok) {
      return json(
        { error: "PayPal order creation failed", details: orderJson },
        502,
      );
    }

    const approveLink = orderJson.links?.find(
      (l: { rel: string }) => l.rel === "approve",
    )?.href;

    if (!approveLink) {
      return json(
        { error: "PayPal order created without an approve link", details: orderJson },
        502,
      );
    }

    await admin
      .from("pagos")
      .update({ paypal_order_id: orderJson.id })
      .eq("id", pago.id);

    return json({ orderId: orderJson.id, approveUrl: approveLink });
  } catch (err) {
    return json({ error: String(err) }, 500);
  }
});
