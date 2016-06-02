output "fleet_ui" {
  value = "http://${aws_elb.FleetUI-elb.dns_name}"
}

output "etcd_browser" {
  value = "http://${aws_elb.etcd-browser-elb.dns_name}"
}

output "sshuttle" {
  value = "sshuttle -r ubuntu@${aws_instance.sshuttle.public_ip} 0/0 -D"
}
