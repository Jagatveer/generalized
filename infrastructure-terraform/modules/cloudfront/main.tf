resource "aws_s3_bucket" "cf-bucket" {
      bucket = "${var.service_name}-${var.environment}"
  acl    = "public-read-write"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  aliases = ["${var.service_name}-${var.environment}.<client>app.com"]
  comment             = "distribution ${var.service_name}-${var.environment} with an ELB origin"
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    compress         = "false"
    default_ttl      = "0"
    forwarded_values {
      cookies {
        forward = "none"
      }
      headers = ["Origin"]
      query_string = false
    }
    max_ttl          = 86400
    min_ttl          = 0
    target_origin_id = "Origin-${var.service_name}-${var.environment}"
    viewer_protocol_policy = "redirect-to-https"
  }
  enabled             = true
  http_version        = "http1.1"
  is_ipv6_enabled     = false
  origin {
    domain_name = "${aws_s3_bucket.cf-bucket.bucket_regional_domain_name}"
    origin_id   = "Origin-${var.service_name}-${var.environment}"
    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }
  price_class         = "PriceClass_All"
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  depends_on = ["aws_cloudfront_origin_access_identity.origin_access_identity"]
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Access S3 bucket content only through CloudFront"
  depends_on = ["aws_s3_bucket.cf-bucket"]
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.cf-bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.cf-bucket.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_bucket_cdn_policy" {
  bucket = "${aws_s3_bucket.cf-bucket.id}"
  policy = "${data.aws_iam_policy_document.s3_policy.json}"
}
