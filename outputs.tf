output "load_balancer_addresses" {
  description = "The URLs of the ECS clusters load balancers"
  value       = module.vpc.load_balancer_addresses
}
