variable "blue_weight" {
  description = "Traffic weight for the Blue environment"
  type        = number
  default     = 100
}

variable "green_weight" {
  description = "Traffic weight for the Green environment"
  type        = number
  default     = 0
}

variable "blue_target_group_name" {
  description = "Name of the Blue target group"
  type        = string
  default     = "cmtr-7zh97qyv-blue-tg"
}

variable "green_target_group_name" {
  description = "Name of the Green target group"
  type        = string
  default     = "cmtr-7zh97qyv-green-tg"
}

variable "blue_launch_template_name" {
  description = "Name of the Blue launch template"
  type        = string
  default     = "cmtr-7zh97qyv-blue-template"
}

variable "green_launch_template_name" {
  description = "Name of the Green launch template"
  type        = string
  default     = "cmtr-7zh97qyv-green-template"
}

variable "blue_asg_name" {
  description = "Name of the Blue Auto Scaling Group"
  type        = string
  default     = "cmtr-7zh97qyv-blue-asg"
}

variable "green_asg_name" {
  description = "Name of the Green Auto Scaling Group"
  type        = string
  default     = "cmtr-7zh97qyv-green-asg"
}

variable "load_balancer_name" {
  description = "Name of the Application Load Balancer"
  type        = string
  default     = "cmtr-7zh97qyv-lb"
}