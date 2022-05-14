# Custom FluentBit Image

## Authenticate with Docker

```
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <id>.dkr.ecr.us-east-1.amazonaws.com
```

## Build the Image

```
docker buildx build --platform linux/amd64 -t fluent-bit-s3 .

docker tag fluent-bit-s3:latest <id>.dkr.ecr.us-east-1.amazonaws.com/fluent-bit-s3:latest
```

## Push the Image

```
docker push <id>.dkr.ecr.us-east-1.amazonaws.com/fluent-bit-s3:latest
```