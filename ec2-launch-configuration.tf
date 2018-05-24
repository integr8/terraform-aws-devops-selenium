data "template_file" "tpl_selenium-ecs-config" {
  template = "${file("${path.module}/custom/ecs.config")}"

  vars = {
    cluster-name = "${var.cluster-name}"
  }
}

data "template_file" "tpl_selenium-cloud-config" {
  template = "${file("${path.module}/custom/cloudinit.sh")}"

  vars = {
    bucket-name = "${aws_s3_bucket.s3_selenium.id}"
  }
}

resource "tls_private_key" "kp-create_selenium" {
  algorithm = "RSA"

  provisioner "local-exec" {
    command = "echo '${tls_private_key.kp-create_selenium.private_key_pem}' > ${path.cwd}/outputs/pk_selenium"
  }
}

resource "aws_iam_instance_profile" "iam-ins-profile_selenium" {
  name = "iam-ins-profile_selenium"
  role = "${aws_iam_role.iam_selenium-ec2-role.id}"
}

resource "aws_key_pair" "kp_selenium" {
  key_name   = "kp_selenium"
  public_key = "${tls_private_key.kp-create_selenium.public_key_openssh}"

  depends_on = ["tls_private_key.kp-create_selenium"]
}

resource "random_id" "bucket-name" {
  byte_length = 12
  prefix      = "${var.bucket-name-prefix}"
}

resource "aws_s3_bucket" "s3_selenium" {
  bucket = "${random_id.bucket-name.hex}"
}

resource "aws_s3_bucket_object" "s3_selenium-object" {
  bucket  = "${aws_s3_bucket.s3_selenium.id}"
  key     = "ecs.config"
  content = "${data.template_file.tpl_selenium-ecs-config.rendered}"
}

resource "aws_launch_configuration" "launch-config_selenium" {
  name                 = "launch-config_selenium"
  image_id             = "${var.ami}"
  instance_type        = "${var.instance-type}"
  key_name             = "${aws_key_pair.kp_selenium.key_name}"
  user_data            = "${data.template_file.tpl_selenium-cloud-config.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.iam-ins-profile_selenium.id}"
  security_groups      = ["${aws_security_group.sg-ec2_selenium.id}"]
}
