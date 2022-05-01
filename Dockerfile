FROM adoptopenjdk/openjdk11:alpine-jre

WORKDIR /app

ADD target/*.jar app.jar

ENTRYPOINT exec java -jar /app/app.jar


