variable "name" {
    description = "The name of the database"
    type        = string
    default = "default_db"
}

variable "hash_key" {
    description = "The name of the hash key"
    type        = string
    default = "id"
}

variable "hash_key_type" {
    description = "The type of the hash key (S, N, or B)"
    type        = string
    default = "S"
}

variable "range_key" {
    description = "The name of the range key (optional)"
    type        = string
    default = ""
}

variable "range_key_type" {
    description = "The type of the range key (S, N, or B)"
    type        = string
    default = "S"
}

variable "stream_enabled" {
    description = "Whether to enable DynamoDB Streams"
    type        = bool
    default     = false
}

variable "stream_view_type" {
    description = "The view type for DynamoDB Streams (NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES, or KEYS_ONLY)"
    type        = string
    default     = "NEW_IMAGE"
}

variable "tags" {
    description = "A map of tags to assign to the DynamoDB table"
    type        = map(string)
    default     = {}
}