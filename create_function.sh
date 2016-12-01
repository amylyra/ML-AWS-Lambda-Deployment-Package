#!/bin/bash

aws lambda create-function --function-name  ????\
--region us-west-1 \
--runtime python2.7 \
--role "arn:aws:iam::>>>>>>>" \
--code S3Bucket=???,S3Key=???.zip \
--handler run.handler
