#!/bin/bash
aws s3 cp lambda.zip s3://lambdaplayground/
aws lambda update-function-code \
--region us-west-1 \
--function-name ??????\
--s3-bucket ??? --s3-key lambda.zip
