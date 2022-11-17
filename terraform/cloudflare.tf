## Cloudflare DNS records and API Secret

resource "kubernetes_secret" "cloudflare_api_key_secret" {

  depends_on = [
    kubernetes_namespace.certmanager
  ]

  metadata {
    name = "cloudflare-api-key-secret"
    namespace = "certmanager"
  }

  data = {
    api-key = var.cloudflare_api_key
  }

  type = "Opaque"
}

resource "cloudflare_record" "kube-ravilushqa-dev-certificate" {
  zone_id = var.cloudflare_zone_id
  name    = "*.kube.ravilushqa.dev"
  type    = "A"
  value   = module.kube-hetzner.ingress_public_ipv4
  proxied = false
}