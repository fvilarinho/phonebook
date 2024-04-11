# Phonebook - An OpenTelemetry demo application

## 1. Introduction
This application has the intention to demonstrate how to enable observability (collection of metrics, traces & logs) in 
an application services (Frontend, Backend & Database) with OpenTelemetry and store the data in Prometheus (for metrics)
and Jaeger (for traces).

It also provides some dashboards for Data Visualization tool [Grafana](https://www.grafana.com). You just need to import them.

## 2. Maintainers
- [Felipe Vilarinho](https://www.linkedin.com/in/fvilarinho)

If you want to collaborate in this project, reach out us by e-Mail.

You can also fork and customize this project by yourself once it's opensource. Follow the requirements below to set up 
your build environment.

## 3. Requirements

### To build, package and publish
- [JDK 17 or later](https://www.oracle.com/java/technologies/downloads)
- [Docker 24.x or later](https://www.docker.com)
- `Any linux distribution with Kernel 5.x or later` or
- `MacOS - Catalina or later` or
- `MS-Windows 10 or later with WSL2`
- `Dedicated machine with at least 4 CPU cores and 8 GB of RAM`

Just execute the shell script `build.sh` to start the building process. Execute `package.sh` to start the packaging, and 
execute`publish.sh` to publish the built packages in the repository.

The following variables must be set in your build environment file `.env` that is located in the root directory of this
project. Please use the file `.env.template` as template.

- `DOCKER_REGISTRY_URL`: Define the Docker Registry Repository URL to build and store the container images. (For 
example, to use [Docker HUB](https://hub.docker.com), the value will be `docker.io`. To use 
[GitHub Packages]('https://github.com'), the value will be `ghcr.io`. Please check the instructions of your Docker 
Registry repository).
- `DOCKER_REGISTRY_ID`: Define the Docker Registry Repository Identifier (Usually it's the username, but check the 
instructions of your Docker Registry repository).
- `BUILD_VERSION`: Define the version of the container images.
- `DB_HOST`: Define the hostname of the database. By default, it uses the local container service.
- `DB_NAME`: Define the name of the database.
- `DB_USER`: Define the username connect in the database.
- `DB_PASS`: Define the password to connect in the database.
- `DB_ROOT_PASS`: Define the root password of the database.
- `APP_USER`: Define the username to authenticate in the application.
- `APP_PASS`: Define the password to authenticate in the application.
  
The following environment variable must be set in your operating system.
- `DOCKER_REGISTRY_PASSWORD`: Define the Docker Registry Repository Password.

### To start / stop locally
Just execute the shell script `start.sh` (after the setup) to start the stack locally, and execute `stop.sh` to stop the
stack locally.

### To deploy
First, you need to define the credentials of Akamai Connected Cloud. Please check the Settings / Resources sections 
below.
After the credentials are defined, just execute the shell script `deploy.sh` to start the provisioning, and execute 
`undeploy.sh` for de-provisioning.

### To access
To access the stack UI, just open your browser and type the URL: `[http|https]://<hostname>/ui` and the login prompt 
will appear. For local access, use localhost, for remote access, use the IP/Hostname of the provisioned infrastructure.

To access the Metrics Server UI (Prometheus), just open your browser and type the URL: `[http|https]://<hostname>:9090`. 
For local access, use localhost, for remote access, use the IP/Hostname of the provisioned infrastructure.

To access the Traces Server UI (Jaeger), just open your browser and type the URL: `[http|https]://<hostname>:16686`.
For local access, use localhost, for remote access, use the IP/Hostname of the provisioned infrastructure.

## 4. Settings
If you want to customize the stack by yourself, just edit the following files:
- `iac/.credentials`: Defines the Akamai Connected Cloud credentials. Please use the file `iac/.credentials.template` as
template.
- `iac/settings.json`: Defines the Akamai Connected Cloud provisioning settings to be used. Please use the file `iac/settings.json.template` 
as template.
- `iac/main.tf`: Defines the required provisioning providers.
- `iac/variables.tf`: Defines the provisioning variables.
- `iac/linode.tf`: Defines the Akamai Connected Cloud provider.
- `iac/linode-instances.tf`: Defines the instances to be provisioned in Akamai Connected Cloud.
- `iac/linode-certificates.tf`: Defines the TLS certificates to be provisioned.
- `iac/linode-firewall.tf`: Defines the firewall rules to be provisioned.
- `iac/docker-compose.yml`: Defines how the application stack is composed.
- `etc/frontend.conf`: Defines the Frontend service configurations.
- `etc/prometheus.conf`: Defines the Prometheus service configurations.
- `etc/otel_*.json`: OpenTelemetry Dashboards definition.
- `Dockerfile`: Defines the container images of the application.

## 5. Other resources
- [Akamai Connected Cloud](https://www.linode.com/)
- [OpenTelemetry](https://opentelemetry.io/)
- [Prometheus](https://prometheus.io/)
- [Jaeger](https://www.jaegertracing.io/)
- [Grafana](https://www.grafana.com/)

Additionally, you can create an Akamai Property and enable [Akamai Datastream 2](https://techdocs.akamai.com/datastream2/docs/welcome-datastream2)
to collect the CDN traffic logs and/or [Akamai SIEM Integration](https://techdocs.akamai.com/siem-integration/docs/welcome-siem-integration)
for security logs. These logs can be stored in [Hydrolix](https://www.hydrolix.io). Check it out this [repo](https://www.github.com/fvilarinho/hydrolix-demo)
to know how to provision it.

And that's it! Have fun!
