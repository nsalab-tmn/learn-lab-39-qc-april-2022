variable prefix {
  default = "student"
}

variable lab_instance {
  default = "qc22"
}

variable dns_root {
  default = "skillscloud.company"
}

variable "rustack_admin_token" {
    type        = string

    # Self client admin
    default     = "054be40e142bede48c0721c36f9e88c327107a2c"

    # Guest client admin
    # default     = "591cac98d205ceaae742d236ecce4a1bd614acba"
    
}

variable "rustack_root_token" {
    type        = string
    default     = "04ffede6415eb4f6bd9b24648e4dba2761b55d5e"   
}

variable "rustack_domain" {
    type        = string
    default     = "778481b3-5059-4a3c-a3f8-749631c2ff91"
    # cloud.nsalab.org
}

variable "rustack_entity" {
    type        = string
    
    # Self client
    default     = "ca76cafa-72f4-4aa0-8815-64780f445426"
    
    # Guest client
    # default     = "35c60cf7-acb8-4035-bcc3-63acf4152e01"
    
}

variable "rustack_api_endpoint" {
    type        = string
    default     = "https://cloud.nsalab.org"
}

variable "s3_endpoint" {
    type        = string
    default     = "https://s3.sbcloud.online"
}

variable "s3_bucket_images" {
    type        = string
    default     = "nsalab/images/${var.lab_instance}"
}

variable "s3_bucket_labs" {
    type        = string
    default     = "nsalab/eve-labs/${var.lab_instance}"
}

variable "s3_access_key" {
    type        = string
    default     = "MMX8Y3VVBBTXEKB42Q9D"
}

variable "s3_secret_key" {
    type        = string
    default     = "yAQkZ3HbnMAu9ExUA9SkI6HbNy6gFFZj6UW0IgKY"
}