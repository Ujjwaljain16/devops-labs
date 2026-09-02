# Stage 1: Build Java Application
FROM openjdk:17-jdk-alpine AS builder

WORKDIR /build
COPY App.java .
RUN javac App.java

# Stage 2: Minimal Runtime
FROM openjdk:17-jdk-alpine

WORKDIR /app
COPY --from=builder /build/App*.class ./

EXPOSE 8080

CMD ["java", "App"]
