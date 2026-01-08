## ===== BUILD STAGE ===== ##
FROM maven:3.9.1-eclipse-temurin-17-alpine AS build
WORKDIR /app/build/
COPY pom.xml .
RUN --mount=type=cache,target=/root/.m2 mvn dependency:go-offline
COPY . .
RUN --mount=type=cache,target=/root/.m2 mvn clean package -DskipTests
## ===== RUNTIME STAGE ===== ##
FROM eclipse-temurin:17-jre-alpine
ENV TZ=Asia/Ho_Chi_Minh
WORKDIR /app/run/
COPY --from=build /app/build/target/*.jar app.jar
EXPOSE 8080
CMD ["java", "-jar", "-Xms256m", "-Xmx1500m", "app.jar"]