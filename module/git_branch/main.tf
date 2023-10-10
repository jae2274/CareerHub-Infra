

variable "branch_to_prefix_map" {
  type = map(string)
}

variable "prefix_separator" {
  type = string
  default = "_"
}

variable "return_key_if_not_found" {
  type = bool
  default = true
}

data external git_branch{
  program = ["${path.module}/git_branch.sh"  ]
}

locals{
  branch = data.external.git_branch.result["branch"]
  prefix = var.return_key_if_not_found ? lookup(var.branch_to_prefix_map, local.branch, local.branch) : var.branch_to_prefix_map[local.branch]
}

output branch{
  value = local.branch
}

output "prefix" {
  value = length(local.prefix) > 0 ? "${local.prefix}${var.prefix_separator}" : ""
}