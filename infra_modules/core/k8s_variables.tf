variable "master_public_ip" {
  type = string
}

variable "worker_ips" {
  type = list(string)
}

variable "kubeconfig_secret_id" {
  type = string
}
