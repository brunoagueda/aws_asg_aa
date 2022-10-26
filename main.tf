resource "aws_launch_template" "as_config" {
  name = "teste-asg-launch-template"
  image_id = "ami-07a53499a088e4a8c"
  instance_type = "t2.micro"
  user_data = filebase64("./Scripts/install_script.tpl")
}

resource "aws_autoscaling_group" "asg" {
  name = "asg-teste"
  availability_zones = ["us-east-1a"]
  desired_capacity = 1
  max_size = 2
  min_size = 1
  launch_template {
    id = aws_launch_template.as_config.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_lifecycle_hook" "lch-out" {
  name = "scale_out"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  default_result = "ABANDON"
  heartbeat_timeout = 3600
  lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
}
