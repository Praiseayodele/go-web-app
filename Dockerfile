# --------- Build Stage ---------
FROM golang:1.22 AS base

WORKDIR /app

# Copy module files and download dependencies
COPY go.mod .
RUN go mod download

# Copy all source code
COPY . .

# Build a fully static binary for Linux
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o main .

# --------- Final Stage (Distroless) ---------
FROM gcr.io/distroless/base

# Set working directory to /app to match Go code
WORKDIR /app

# Copy the static binary and static folder
COPY --from=base /app/main ./main
COPY --from=base /app/static ./static

# Expose port for HTTP
EXPOSE 8080

# Run the binary in foreground
CMD ["./main"]
