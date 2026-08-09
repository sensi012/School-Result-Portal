variable "project_name" { 
    type = string 
    }
variable "environment" { 
    type = string 
    }
variable "vpc_id" { 
    type = string 
    }
variable "public_subnet_ids" { 
    type = list(string) 
    }
variable "app_target_group_arn" { 
    type = string 
    }