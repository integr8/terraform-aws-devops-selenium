output "selenium-loadbalancer-dns-name" {
  value = "${aws_alb.alb-selenium.dns_name}"
}
