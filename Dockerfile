FROM eclipse-temurin:17-jre
2
 
3
WORKDIR /app
4
 
5
COPY target/employee-api-1.0.0.jar app.jar
6
 
7
EXPOSE 8080
8
 
9
ENTRYPOINT ["java","-jar","app.jar"]