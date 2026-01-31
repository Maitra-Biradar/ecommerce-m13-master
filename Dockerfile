# -------- Stage 1 : Build --------
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app
# Copy Maven settings first
COPY settings.xml /root/.m2/settings.xml
# Copy pom.xml and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -s /root/.m2/settings.xml
# Copy source code
COPY src ./src
# Build application
RUN mvn clean package -DskipTests -s /root/.m2/settings.xml


# -------- Stage 2 : Run --------
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
# Copy jar from build stage
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8085
ENTRYPOINT ["java","-jar","app.jar"]
