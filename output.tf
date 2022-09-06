

output "zones"{
   value = data.aws_availability_zones.available.names
}

output "countofaz"{
    value = length(data.aws_availability_zones.available.names)
}