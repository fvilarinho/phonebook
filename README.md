Getting Started
---------------

### Introduction
This is a demo project for education/training purposes of software development, Cloud Computing and DevOps.

### Requirements
- [`Java JDK 17.x or later`](https://www.oracle.com/java/technologies/javase/jdk21-archive-downloads.html)
- [`docker 27.x`](https://www.docker.com)
- [`curl 8.12.x`](https://curl.se/)
- [`jq 1.7.x`](https://jqlang.org/)
- [`snyk 1.x`](https://snyk.io/)
- [`htpasswd`](https://httpd.apache.org/docs/trunk/programs/htpasswd.html)
- [`Github account`](https://github.com) - Please check the file `.github/workflows/pipeline.yml` to define the steps to
be executed in the pipeline.
- [`Sonarcloud account`](https://sonarcloud.io)

To Run Locally:
- [`docker 27.x`](https://www.docker.com)
- [`openssl 3.x`](https://openssl.org)
- [`htpasswd`](https://httpd.apache.org/docs/trunk/programs/htpasswd.html)

### Components
- **Frontend**: It contains the UI of the application. It runs [`NGINX`](https://nginx.org/)
- **Backend**: It contains the backend with all business logic of the application. It runs [`Spring Boot`](https://spring.io/projects/spring-boot)
- **Database**: It contains the database to store the application data. It runs [`MongoDB`](https://www.mongodb.com/)

All components are containerized. (Please check the files `docker-compose.tf` and `Dockerfile` for more details).

### Important notes
It's not a good practice to commit any sensitive data in the repository so...

**DON'T EXPOSE OR COMMIT ANY SENSITIVE DATA IN THE PROJECT.**

### Contact
**LinkedIn:**
- https://www.linkedin.com/in/fvilarinho

**e-Mail:**
- fvilarinho@gmail.com
- fvilarinho@outlook.com
- me@vila.net.br

and that's all! Have fun!