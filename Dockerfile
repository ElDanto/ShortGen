FROM golang:1.24.0-alpine3.21 as builder
WORKDIR /src
COPY go.* ./
RUN go mod download
COPY . ./
RUN GOOS=linux GOARCH=amd64 go build -o server ./cmd/server
RUN GOOS=linux GOARCH=amd64 go build -o cron ./cmd/cron

FROM alpine:3.21 as app
RUN apk --no-cache upgrade && apk --no-cache add ca-certificates
COPY --from=builder /src/server /usr/local/bin/server
COPY --from=builder /src/cron /usr/local/bin/cron
COPY --from=builder /src/deploy_conf.yaml /usr/local/bin/conf.yaml
COPY --from=builder /src/internal/config/cron/config.yaml /usr/local/bin/configs/cron/config.yaml
#COPY --from=builder /src/internal/config/server/config.yaml /usr/local/bin/configs/server/confing.yaml

WORKDIR /usr/local/bin/

CMD ["cron", ";", "server"]
