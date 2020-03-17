## Builder image
FROM golang:1.12.1-alpine AS builder

RUN apk add --no-cache ca-certificates git

WORKDIR /src

COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . .

RUN GOOS=linux GOARCH=arm GOARM=5 CGO_ENABLED=0 go build -o /dist/hera

## Final image
FROM alpine:3.8

RUN apk add --no-cache ca-certificates curl gcompat

RUN curl -L -s https://github.com/just-containers/s6-overlay/releases/download/v1.21.4.0/s6-overlay-arm.tar.gz \
  | tar xvzf - -C /

RUN curl -L -s https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-arm.tgz \
  | tar xvzf - -C /bin

RUN apk del --no-cache curl

COPY --from=builder /dist/hera /bin/

COPY rootfs /

ENTRYPOINT ["/init"]
