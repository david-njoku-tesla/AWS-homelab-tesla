# Alarme si > 100 objets dans le bucket (simulation prod)
resource "aws_cloudwatch_metric_alarm" "s3_alert" {
  alarm_name          = "Tesla-S3-TooManyObjects-DavidNjoku"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "BucketSizeBytes"
  namespace           = "AWS/S3"
  period              = 86400
  threshold           = 1000000000  # 1 GB
  alarm_description    = "Alerte David Njoku - Backup trop gros"

  dimensions = {
    BucketName = aws_s3_bucket.tesla_backup.bucket
    StorageType = "StandardStorage"
  }
}
