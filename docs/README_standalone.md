
This part will show you how to build and start a Docker image that contain all the ODM component in one container.



![Flow](images/ClusterFig01.png)

This tutorial applies to IBM ODM Standard V8.9.0.x and previous versions back as far as IBM ODM V8.7.0. 

First, you need to install [Docker and Docker Compose](https://docs.docker.com/compose/#installation-and-set-up).

## Setup your environment

### ODM Installation.
To create this IBM ODM Docker image, you need to install one of the following parts of IBM ODM:         
* Decision Center (WebSphere Liberty Profile option)
* Decision Server Rules (WebSphere Liberty Profile option)

On the file system where you installed IBM ODM V8.8.x or V8.9.x with WebSphere Liberty Profile option, find the required WAR files in the following locations:

*installation_directory/executionserver/applicationservers/WLP855/res.war*

*installation_directory/executionserver/applicationservers/WLP855/DecisionService.war*

*installation_directory/teamserver/applicationservers/WLP855/teamserver.war*

*installation_directory/teamserver/applicationservers/WLP855/decisioncenter.war*

*installation_directory/executionserver/applicationservers/WLP855/DecisionRunner.war*

### Clone the odm-ondocker code 

```git clone http://github.com/lgrateau/odm-ondocker/``` in the IBM ODM installation directory.

### Copy .dockerignore file

Copy the odm-ondocker/src/main/resources/.dockerignore file in your IBM ODM installation directory.

```cp odm-ondocker/src/main/resources/.dockerignore ./```

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
docker-compose -f odm-cluster.yml up
```

This command creates one docker container with the following component:

* Embedded Derby database
* HA Proxy load balancer.
* ODM Decision Server runtime.
* ODM Decision Server console
* ODM Business Console
* ODM Teamcenter.
* ODM Decision Runner.

You can access the application with this URLs:

|Component|URL|Username|Password|
|:-----:|:-----:|:-----:|:-----:|
| [Decision Server Console](http://localhost:9080/res) | <http://localhost:9080/res> |resAdmin|resAdmin|
| [Decision Server Runtime](http://localhost:9080/DecisionService) |<http://localhost:9080/DecisionService> |N/A|N/A|
| [Decision Center]( http://localhost:9080/decisioncenter) |  <http://localhost:9080/decisioncenter> |rtsAdmin|rtsAdmin|
| [Decision Runner]( http://localhost:9080/decisioncenter) |  <http://localhost:9080/testing> |resDeployer|resDeployer|
| [Teamserver]( http://localhost:9080/decisioncenter) |  <http://localhost:9080/teamserver> |rtsAdmin|rtsAdmin|

## Verify the Docker images

You can check the container status with the following command: 
```
 docker-compose ps
```