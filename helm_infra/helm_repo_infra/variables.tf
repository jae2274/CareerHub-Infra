variable "prefix" {
  type = string
}

variable "helm_path" {
  type = string
}

variable "chart_values" {
  type = any //TODO: 어떤 타입이 적절합니까?
}

variable "env_value" {
  type = string
}
