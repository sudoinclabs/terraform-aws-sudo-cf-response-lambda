variable "lambda_code_path" {
  type = string
  description = "(optional) Specify the lambda code directory relative to your terraform root."
  default = ""
}

variable "lambda_env_vars" {
  default     = {}
  description = "(optional) Specify a mapping of evnironment variables for lambda resource."
  type        = map(string)
}

variable "timeout" {
  type = number
  description = "(optional) Timeout value."
  default = 3
}