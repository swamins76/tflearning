#Create a web server through bootstrap method
resource "aws_instance" "tfwebserverwest" {
    provider = aws.west
    ami = "ami-03af6a70ccd8cb578"
    instance_type = "t2.micro"
    tags = {
        Name = "TFcreated"
        env = "${terraform.workspace}"
    }
  
}