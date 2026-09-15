# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "nextjs_app_fqdn" {
  description = "FQDN of the Next.js Container App"
  value       = module.nextjs.fqdn_url
}

output "dotnet_api_fqdn" {
  description = "FQDN of the .NET API Container App"
  value       = module.dotnet_api.fqdn_url
}