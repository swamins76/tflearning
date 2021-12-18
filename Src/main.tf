#Create a web server through bootstrap method
resource "aws_instance" "tfwebserver" {
    ami = "ami-0ed9277fb7eb570c9"
    instance_type = "t2.micro"
    tags = {
        Name = "TFcreated"
        env = "Prod"
    }
  
}