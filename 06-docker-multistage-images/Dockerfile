# ==========================================
# Stage 1: Build Stage (Heavy Go Toolchain)
# ==========================================
FROM golang:1.22-alpine AS builder

WORKDIR /app

# Copy source code
COPY main.go .

# Compile binary statically (no CGO, optimized for minimal image)
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o server main.go

# ==========================================
# Stage 2: Final Production Runtime (Lean)
# ==========================================
FROM alpine:3.19

WORKDIR /app

# Copy only the compiled binary from builder stage
COPY --from=builder /app/server .

# Expose target port 8080
EXPOSE 8080

# Execute server binary
CMD ["./server"]
