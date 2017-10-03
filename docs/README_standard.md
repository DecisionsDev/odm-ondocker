
This part will show you how to start  an ODM unclustered Docker topology for development using Docker Compose.


![Flow](images/Fig1.png)

This tutorial applies to IBM ODM Standard V8.9.0.1 and previous versions back as far as IBM ODM V8.8.x.

First, you need to install [Docker and Docker Compose](https://docs.docker.com/compose/#installation-and-set-up).

## Setup your environment

### ODM Installation.
To create IBM ODM Docker images, you need to install one of the following parts of IBM ODM:         
* Decision Center (WebSphere Liberty Profile option)
* Decision Server Rules (WebSphere Liberty Profile option)

On the file system where you installed IBM ODM V8.8.x or V8.9.x with WebSphere Liberty Profile option, find the required WAR files in the following locations:

*installation_directory/executionserver/applicationservers/WLP855/res.war*

*installation_directory/executionserver/applicationservers/WLP855/DecisionService.war*

*installation_directory/teamserver/applicationservers/WLP855/teamserver.war*

*installation_directory/teamserver/applicationservers/WLP855/decisioncenter.war*

*installation_directory/executionserver/applicationservers/WLP855/DecisionRunner.war*

### Clone the odm-ondocker code

```git clone https://github.com/ODMDev/odm-ondocker.git``` in the IBM ODM installation directory.

### Copy .dockerignore file

Copy the odm-ondocker/resources/.dockerignore file in your IBM ODM installation directory.

```cp odm-ondocker/resources/.dockerignore ./```

At the end of this steps you should have something like that :

![Flow](images/Fig2.png)
### Verify that Docker Engine and Docker Compose are running.

Open a command prompt and run the following two operations:    	

  ```
    > docker -–version
    Docker version 1.12.3
    > docker-compose version
    docker-compose version 1.8.1
  ```

Now you are ready to build and run the Docker images.

## Build and run the docker image
Open a command prompt in the directory **installation_directory/odm-ondocker** and run the following command:    	

```
docker-compose  up
```

This command builds, creates, and runs five Docker containers:

* Derby Network database server
* ODM Decision Server runtime
* ODM Decision Server console
* ODM Decision Center
* ODM Decision Runner

If the Docker container is not already built, Docker Compose builds it and runs it.

You could also start only one of the components.

For example: ```docker-compose up decisioncenter``` starts the Decision Center and its dependencies, including the dbserver Derby Network server.

You can access the application with this URLs:

|Component|URL|Username|Password|
|:-----:|:-----:|:-----:|:-----:|
| [Decision Server Console](http://localhost:9080/res) | <http://localhost:9080/res> |resAdmin|resAdmin|
| [Decision Server Runtime](http://localhost:9090/DecisionService) |<http://localhost:9090/DecisionService> |N/A|N/A|
| [Decision Center Business Console]( http://localhost:9060/decisioncenter) |  <http://localhost:9060/decisioncenter> |rtsAdmin|rtsAdmin|
| [Decision Center Enterprise Console]( http://localhost:9060/teamserver) |  <http://localhost:9060/teamserver> |rtsAdmin|rtsAdmin|
| [Decision Runner]( http://localhost:9070/DecisionRunner) |  <http://localhost:9070/DecisionRunner> |resDeployer|resDeployer|


## Verify the Docker images

You can check the container status with the following command:
```
 docker-compose ps
```
 The following screen capture shows the list of running containers.

![Flow](images/StandardFig02.png)
