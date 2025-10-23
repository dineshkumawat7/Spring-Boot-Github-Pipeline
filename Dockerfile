# ============================================
# Stage 1: Build the Spring Boot application
# ============================================

# Base Image: Maven with Eclipse Temurin JDK 21
# - 'maven:3.9.9-eclipse-temurin-21' includes Maven 3.9.9 and JDK 21 (Temurin distribution)
# - Ideal for building Java applications using Maven
# - Provides both the JDK (for compilation) and Maven (for dependency management & packaging)
FROM maven:3.9.9-eclipse-temurin-21 AS build

# Maintainer / Metadata
LABEL maintainer="dkumawat7627@gmail.com"
LABEL stage="build"
LABEL description="Build stage for Spring Boot application"

# Set working directory inside container
WORKDIR /app

# Copy only the pom.xml and download dependencies first (for better caching)
COPY pom.xml ./

# Download Maven dependencies (cached for faster builds)
RUN mvn -B dependency:go-offline -e -X

# Copy the rest of the source code into the container
COPY src ./src

# Package the application (skip tests for faster image build)
# # -e enables error details, -X enables full debug logs
RUN mvn clean package -DskipTests -e -X

# =============================================
# Stage 2: Create a lightweight runtime image
# =============================================

# Base Image: Eclipse Temurin JRE 21 on Alpine Linux
# - 'eclipse-temurin:21-jre-alpine' provides a small, optimized Java runtime (no compiler)
# - Suitable for running already-built JAR files
# - Alpine base keeps the final image small and efficient
FROM eclipse-temurin:21-jre-alpine

# Maintainer / Metadata
LABEL maintainer="dkumawat7627@gmail.com"
LABEL stage="runtime"
LABEL description="Lightweight runtime image for Spring Boot app"

# Set working directory
WORKDIR /app

# Create a non-root user for security
# - 'appuser' belongs to group 'appgroup'
# - no password, non-root UID
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy the JAR file from the build stage
COPY --from=build /app/target/*.jar app.jar

# Change ownership of the JAR file to the non-root user and group
RUN chown appuser:appgroup app.jar

# Switch to the non-root user for security
USER appuser

# Expose application port
EXPOSE 8080

# Run the Spring Boot application
ENTRYPOINT ["java", "-jar", "app.jar"]
