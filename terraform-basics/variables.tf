variable "instance_type" {
    description = "The type of instance to use for the EC2 instance."
    type        = string
    default     = "t3.micro"
}

variable "instance_tags" {
    description = "A map of tags to assign to the EC2 instance."
    type        = map(string)
    default     = {
        Name = "MyInstance"
    }

}