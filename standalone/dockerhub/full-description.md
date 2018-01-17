
# Quick reference

-	**Where to get help**:   [The ODMDev community](https://developer.ibm.com/odm/)

-	**Where to file issues**:  
  https://github.com/ODMDev/odm-ondocker/issues

-	**Maintained by**:   [The IBM WASdev Community](https://github.com/ODMDev)

-	**Supported architectures**:  ([more info](https://github.com/docker-library/official-images#architectures-other-than-amd64))

  [`amd64`](https://hub.docker.com/r/amd64/websphere-liberty/), [`i386`](https://hub.docker.com/r/i386/websphere-liberty/), [`ppc64le`](https://hub.docker.com/r/ppc64le/websphere-liberty/), [`s390x`](https://hub.docker.com/r/s390x/websphere-liberty/)

  -	**Source of this description**:  
  docs repo's odm/(https://github.com/ODMDev/odm-ondocker/tree/master/standalone/dockerhub) directory (history)

  -	**Supported Docker versions**:  
  	[the latest release](https://github.com/docker/docker-ce/releases/latest) (down to 1.6 on a best-effort basis)

  # Overview

  The images in this repository contain IBM Operational Decision Manager for Developers based on IBM Websphere Application Server Liberty for Developper image. See the license section below for restrictions relating to the use of this image. For more information about  IBM Operational Decision Manager , see the [ODMDev](https://www.ibm.com/support/knowledgecenter/en/SSQP76_8.9.1/com.ibm.odm.dserver.rules.tutorials/tut_gs_topics/odm_dserver_rules_gs.html) site.


  # Usage

This image contain the IBM Operational Decision Manager with all the component in a single image.
This allow to evaluate products.

1.	This  image contains a server pre-configure with a database that is accessible  9060 and 9443 for HTTP and HTTPS respectively.

  	```console
  	$ docker run -e LICENSE=accept -p 9060:9060 -p 9443:9443 \
  	    ibmcom/odm
  	```
You need to accept the license before launching this image. License is available in the bottom of this page.

When the server is started, you can access the application with these URLs:

|Component|URL|Username|Password|
|:-----:|:-----:|:-----:|:-----:|
| [Decision Server Console](http://localhost:9060/res) | <http://localhost:9060/res> |resAdmin|resAdmin|
| [Decision Server Runtime](http://localhost:9060/DecisionService) |<http://localhost:9060/DecisionService> |N/A|N/A|
| [Decision Center Business Console]( http://localhost:9060/decisioncenter) |  <http://localhost:9060/decisioncenter> |rtsAdmin|rtsAdmin|
| [Decision Center Enterprise Console]( http://localhost:9060/teamserver) |  <http://localhost:9060/teamserver> |rtsAdmin|rtsAdmin|
| [Decision Runner]( http://localhost:9060/DecisionRunner) |  <http://localhost:9060/DecisionRunner> |resDeployer|resDeployer|


  # License

  The Dockerfiles and associated scripts are licensed under the [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).

  Licenses for the products installed within the images are as follows:
  -	[IBM Operation Decision Manager for Developper ](https://raw.githubusercontent.com/ODMDev/odm-ondocker/master/standalone/licenses/Lic_en.txt) in the  image
