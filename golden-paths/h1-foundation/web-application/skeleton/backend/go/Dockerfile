FROM golang:1.22-alpine AS build
WORKDIR /app
COPY go.mod ./
COPY *.go ./
RUN CGO_ENABLED=0 go build -o /server

FROM gcr.io/distroless/static
COPY --from=build /server /server
USER 1001
ENTRYPOINT ["/server"]
