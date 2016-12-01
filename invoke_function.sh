#!/bin/bash

aws lambda invoke --invocation-type RequestResponse \
--region us-west-1 \
--payload file://./test/test3.json \
--function-name ???? \
outputfile.json
