output "lb_ip_address" {
  description = "Public IP of the Cloud Armor-protected load balancer."
  value       = google_compute_global_address.lb.address
}

output "cloud_armor_policy" {
  description = "Name of the Cloud Armor WAF policy."
  value       = google_compute_security_policy.armor.name
}

output "test_waf_commands" {
  description = "Commands to test the WAF rules."
  value = <<-EOT
    # Get the LB IP
    LB_IP=${google_compute_global_address.lb.address}

    # Normal request — should return 200
    curl -v http://$LB_IP

    # SQL injection attempt — should return 403 (blocked by Cloud Armor)
    curl -v "http://$LB_IP?id=1'%20OR%20'1'='1"

    # XSS attempt — should return 403
    curl -v "http://$LB_IP?q=<script>alert('xss')</script>"

    # Protocol attack (LFI) — should return 403
    curl -v "http://$LB_IP?file=../../../etc/passwd"

    # Expected: first request succeeds, all others blocked by Cloud Armor WAF.
    # This demonstrates how an NGFW/WAF at the Internet Edge protects web applications.
  EOT
}

output "cost_warning" {
  value = <<-EOT
    ╔══════════════════════════════════════════════════════╗
    ║  COST WARNING                                        ║
    ╠══════════════════════════════════════════════════════╣
    ║ Cloud Armor: FREE (5 rules free tier)               ║
    ║ Cloud IDS: 30-day free trial (not enabled by def)   ║
    ║ HTTP LB: ~$0.025/hr ($0.60/day) ***                 ║
    ║ f1-micro instance: FREE (free tier)                 ║
    ║                                                      ║
    ║ *** HTTP LB is the only paid resource.               ║
    ║ Strategy: 2-hour session = $0.05. Destroy after.     ║
    ╚══════════════════════════════════════════════════════╝
  EOT
}
