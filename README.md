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

To Build, Test, Validate, Package, Publish and Deploy:
- [`Java JDK 21.x or later`](https://www.oracle.com/java/technologies/javase/jdk21-archive-downloads.html)
- [`docker 27.x`](https://www.docker.com)
- [`curl 8.12.x`](https://curl.se/)
- [`jq 1.7.x`](https://jqlang.org/)
- [`snyk 1.x`](https://snyk.io/)
- [`terraform 1.5.x`](https://www.terraform.io)
- [`htpasswd`](https://httpd.apache.org/docs/trunk/programs/htpasswd.html)
- [`certbot 2.11.x`](https://certbot.eff.org/)
- [`Gitea 1.22.x`](https://gitea.com) - Only required if you want to run these workflows in a CI/CD pipeline. Please 
check the file `.gitea/workflows/pipeline.yml` to define the steps to be executed in the pipeline.
- [`Sonarqube 25.3.x`](https://www.sonarsource.com/open-source-editions/sonarqube-community-edition/)
- [`Akamai Cloud Computing account`](https://techdocs.akamai.com/linode-api/reference/get-started)

To Run Locally:
- [`docker 27.x`](https://www.docker.com)
- [`certbot 2.11.x`](https://certbot.eff.org/)
- [`htpasswd`](https://httpd.apache.org/docs/trunk/programs/htpasswd.html)

### Components
- **Frontend**: It contains the UI of the application. It runs [`nginx`](https://nginx.org/)
- **Backend**: It contains the backend with all business logic of the application. It runs [`Spring Boot`](https://spring.io/projects/spring-boot)
- **Database**: It contains the database to store the application data. It runs [`mariadb`](https://mariadb.org/)

All components are containerized. (Please check the files `docker-compose.tf` and `Dockerfile` for more details).

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