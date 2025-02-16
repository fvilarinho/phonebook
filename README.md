Getting Started
---------------

### Introduction
This is a demo project for education/training purposes of software development, Cloud Computing and DevOps.
It does the provisioning of the Akamai Connected Cloud resources that includes:
- **Compute**: VM that will run the application. (Please check the file `iac/compute.tf` for more details).
- **Firewall**: Rules to protect the application. (Please check the file `iac/firewall.tf` for more details).
- **Certificate**: TLS certificate to force HTTPs traffic. (Please check the file `iac/certificate.tf` for more details).
- **Credentials**: SSH key for remote access authentication. (Please check the file `iac/credentials.tf` for more 
details).

All Terraform files use `variables` that are stored in the `variables.tf`. Please check this [link](https://developer.hashicorp.com/terraform/tutorials/configuration-language/variables) to customize 
the variables.

### Requirements

To Build, Test, Validate, Package and Publish:
- [`Java JDK 17.x or later`](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html)
- [`Docker 27.x`](https://www.docker.com)
- [`curl 8.12.x`](https://curl.se/)
- [`jq 1.7.x`](https://jqlang.org/)
- [`snyk 1.x`](https://snyk.io/)
- [`Github Packages Credentials`](https://github.com) or any other docker registry.
- [`Sonarcloud Credentials`](https://sonarcloud.io)
- [`Snyk Credentials`](https://snyk.io)

To Run Locally:
- [`Docker 27.x`](https://www.docker.com)
- [`certbot 2.11.x`](https://certbot.eff.org/)
- [`htpasswd`](https://httpd.apache.org/docs/trunk/programs/htpasswd.html)

To Deploy in Akamai Connected Cloud:
- [`Terraform 1.5.x`](https://www.terraform.io)
- [`jq 1.7.x`](https://jqlang.org/)
- [`htpasswd`](https://httpd.apache.org/docs/trunk/programs/htpasswd.html)
- [`certbot 2.11.x`](https://certbot.eff.org/)
- [`Akamai Cloud Computing Credentials`](https://techdocs.akamai.com/linode-api/reference/get-started)

### Components
- **Frontend**: It contains the UI of the application. It runs [`nginx`](https://nginx.org/)
- **Backend**: It contains the backend with all business logic of the application. It runs [`Spring Boot`](https://spring.io/projects/spring-boot)
- **Database**: It contains the database to store the application data. It runs [`mariadb`](https://mariadb.org/)

All components are containerized. (Please check the file `iac/docker-compose.tf` for more details).

### Important notes
It's not a good practice to commit any sensitive data in the repository so...

**DON'T EXPOSE OR COMMIT ANY SENSITIVE DATA IN THE PROJECT.**

### Documentation

Follow the documentation below to know more about Akamai:
- [**Akamai Techdocs**](https://techdocs.akamai.com)

### Contact
**LinkedIn:**
- https://www.linkedin.com/in/fvilarinho

**e-Mail:**
- fvilarin@akamai.com
- fvilarinho@gmail.com
- fvilarinho@outlook.com
- me@vila.net.br

and that's all! Have fun!