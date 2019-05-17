# Build Stage
FROM golang:1.11-alpine3.9 AS build

# Install tools required for project
# Run `docker build --no-cache .` to update dependencies
# hadolint ignore=DL3018
RUN apk add --no-cache git && go get github.com/golang/dep/cmd/dep

# List project dependencies with Gopkg.toml and Gopkg.lock
# These layers are only re-built when Gopkg files are updated
COPY Gopkg.lock Gopkg.toml /go/src/app/
WORKDIR /go/src/app/
# Install library dependencies
RUN dep ensure -vendor-only

# Build the application
COPY . /go/src/app
RUN go build -o bin/app

# Final Image
FROM alpine:3.9

# hadolint ignore=DL3018
RUN apk update && \
  apk add --no-cache openssl ca-certificates curl

# Install tools required for project
RUN wget https://github.com/Droplr/aws-env/raw/master/bin/aws-env-linux-amd64 -O /bin/aws-env

COPY --from=build /go/src/app/bin /app/

RUN chmod +x /bin/aws-env
WORKDIR /app

#DD_AGENT_HOST can be updated to use service discovery
CMD ["sh", "-c", "eval $(aws-env) && ./app"]
