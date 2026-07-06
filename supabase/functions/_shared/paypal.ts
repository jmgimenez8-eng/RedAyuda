const PAYPAL_MODE = Deno.env.get("PAYPAL_MODE") ?? "sandbox";

export const PAYPAL_BASE_URL =
  PAYPAL_MODE === "live"
    ? "https://api-m.paypal.com"
    : "https://api-m.sandbox.paypal.com";

export async function getPaypalAccessToken(): Promise<string> {
  const clientId = Deno.env.get("PAYPAL_CLIENT_ID");
  const secret = Deno.env.get("PAYPAL_CLIENT_SECRET");
  if (!clientId || !secret) {
    throw new Error("PayPal credentials not configured in function secrets");
  }
  const basicAuth = btoa(`${clientId}:${secret}`);

  const res = await fetch(`${PAYPAL_BASE_URL}/v1/oauth2/token`, {
    method: "POST",
    headers: {
      "Authorization": `Basic ${basicAuth}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: "grant_type=client_credentials",
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`PayPal OAuth failed (${res.status}): ${errText}`);
  }
  const json = await res.json();
  return json.access_token as string;
}
