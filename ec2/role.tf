resource "aws_iam_role" "s3-access" {
  name               = "s3-access"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_instance_profile" "s3-access-instance-profile" {
    name = "s3-access-instance-profile"
    role = aws_iam_role.s3-access.name 
}

resource "aws_iam_role_policy" "s3-access-policy" {
  name = "s3-access-policy"
  role = aws_iam_role.s3-access.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "s3:*"
            ],
            "Resource": [
              "arn:aws:s3:::mybucket-c29df1",
              "arn:aws:s3:::mybucket-c29df1/*"
            ]
        }
    ]
}
EOF

}