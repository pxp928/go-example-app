# Use the official Golang image to create a build artifact.
# This is based on Debian and sets the GOPATH to /go.
# https://hub.docker.com/_/golang
FROM golang:1.17-alpine as builder

# Copy local code to the container image.
WORKDIR /go/src/app
COPY . .

# Run unit tests
RUN CGO_ENABLED=0 GOOS=linux go test

# Build the code inside the container.
RUN CGO_ENABLED=0 GOOS=linux go build -v -o picalc

# Use a Docker multi-stage build to create a lean production image.
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM alpine

# Copy the binary to the production image from the builder stage.
COPY --from=builder /go/src/app/picalc /picalc

# Service must listen to $PORT environment variable.
# This default value facilitates local development.
ENV PORT 8080

# Run the web service on container startup.
CMD ["/picalc"]