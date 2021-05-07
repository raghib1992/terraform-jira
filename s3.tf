resource "aws_s3_bucket_object" "truststore_jks" {
  provider = aws.config_bucket_region
  bucket = var.config_bucket
  key = "${var.name_prefix}/truststore.jks"
  source = "${path.module}/config/truststore.jks"
  etag = filemd5("${path.module}/config/truststore.jks")
  tags = local.common_tags
}

resource "aws_s3_bucket_object" "android_agent" {
  provider = aws.agent_upload_region
  count = var.agent_upload_enabled ? 1 : 0
  bucket = var.agent_upload_bucket
  key = "${var.name_prefix}/android/fhfs.apk"
  source = "${path.module}/agents/android/fhfs.apk"
  etag = filemd5("${path.module}/agents/android/fhfs.apk")
  tags = local.common_tags
}

resource "aws_s3_bucket_object" "linux_agent" {
  provider = aws.agent_upload_region
  count = var.agent_upload_enabled ? 1 : 0
  bucket = var.agent_upload_bucket
  key = "${var.name_prefix}/linux/fhfs.run"
  source = "${path.module}/agents/linux/fhfs.run"
  etag = filemd5("${path.module}/agents/linux/fhfs.run")
  tags = local.common_tags
}

resource "aws_s3_bucket_object" "mac_agent" {
  provider = aws.agent_upload_region
  count = var.agent_upload_enabled ? 1 : 0
  bucket = var.agent_upload_bucket
  key = "${var.name_prefix}/mac/fhfs.pkg"
  source = "${path.module}/agents/mac/fhfs.pkg"
  etag = filemd5("${path.module}/agents/mac/fhfs.pkg")
  tags = local.common_tags
}

resource "aws_s3_bucket_object" "mac_dmg" {
  provider = aws.agent_upload_region
  count = var.agent_upload_enabled ? 1 : 0
  bucket = var.agent_upload_bucket
  key = "${var.name_prefix}/mac/fhfs.dmg"
  source = "${path.module}/agents/mac/fhfs.dmg"
  etag = filemd5("${path.module}/agents/mac/fhfs.dmg")
  tags = local.common_tags
}

resource "aws_s3_bucket_object" "mac_resources" {
  provider = aws.agent_upload_region
  count = var.agent_upload_enabled ? 1 : 0
  bucket = var.agent_upload_bucket
  key = "${var.name_prefix}/mac/resources/bundle.dat"
  source = "${path.module}/agents/mac/resources/bundle.dat"
  etag = filemd5("${path.module}/agents/mac/resources/bundle.dat")
  tags = local.common_tags
}

resource "aws_s3_bucket_object" "win_agent" {
  provider = aws.agent_upload_region
  count = var.agent_upload_enabled ? 1 : 0
  bucket = var.agent_upload_bucket
  key = "${var.name_prefix}/win/fhfs.exe"
  source = "${path.module}/agents/win/fhfs.exe"
  etag = filemd5("${path.module}/agents/win/fhfs.exe")
  tags = local.common_tags
}

resource "aws_s3_bucket_object" "win_resources" {
  provider = aws.agent_upload_region
  count = var.agent_upload_enabled ? 1 : 0
  bucket = var.agent_upload_bucket
  key = "${var.name_prefix}/win/resources/bundle.dat"
  source = "${path.module}/agents/win/resources/bundle.dat"
  etag = filemd5("${path.module}/agents/win/resources/bundle.dat")
  tags = local.common_tags
}
