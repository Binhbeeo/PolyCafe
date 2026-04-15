FROM maven:3.9.6-eclipse-temurin-17 AS build

WORKDIR /app
COPY . .
RUN mvn clean package

FROM tomcat:10.1

RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /app/target/PolyCoffee.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
