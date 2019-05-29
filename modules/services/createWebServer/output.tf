output "elb_dns_name" {

    value = "${aws_elb.webserver-elb.dns_name}"
}

