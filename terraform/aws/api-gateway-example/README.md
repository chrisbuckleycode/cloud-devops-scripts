# AWS API Gateway Example

Boiler plate code example for an AWS API v1 Gateway (REST). Uses AWS' own Pet Store Swagger example. Stage is configured as "beta". No backend, so POST will not persist.

Note: There is also a newer v2 resouce supporting HTTP and WebSocket.

For simplicity, Terraform state is local. Ensure you use a remote backend for production!

## Instructions

Make sure to authenticate to AWS e.g.

```
$ export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
$ export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
$ export AWS_DEFAULT_REGION=us-east-1
```

terraform outputs will show curl urls
e.g.
```
curl_stage_invoke_url_ROOT_GET = "curl https://kc75pjwzzj.execute-api.us-east-1.amazonaws.com/beta"
curl_stage_invoke_url_pets_GET = "curl https://kc75pjwzzj.execute-api.us-east-1.amazonaws.com/beta/pets/"
curl_stage_invoke_url_pets_POST_example = curl -X POST https://kc75pjwzzj.execute-api.us-east-1.amazonaws.com/beta/pets/ -H 'Content-Type: application/json' -d '{"type":"lizard","price":868.89}'
```

(Ignore 'EOT' markers on last output variable. Terraform does not interpolate this curl command easily, I had to make a hack just to get it to work as is, using template file import)


## Future Ideas
- connect to dynamodb
