output "fleet_env" {
  value = "export FLEETCTL_TUNNEL=${aws_elb.aws_elb.FleetCluster-worker-elb.dns_name}:2222\nexport FLEETCTL_STRICT_HOST_KEY_CHECKING=false"
}
