variable "code" {
  type = string
  description = "(optional) Specify the lambda code directory relative to your terraform root"
  default = ""
}

variable "timeout" {
  type = number
  description = "(optional) Timeout value."
  default = 3
}