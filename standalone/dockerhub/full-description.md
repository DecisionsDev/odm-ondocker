
This repository is the home directory of IBM Operational Decision Manager for Developers.

# New: IBM Container Registry

IBM® is now hosting product images on the IBM Container Registry, *icr.io*. You can obtain the IBM Operational Decision Manager for Developers image without authenticating by using this IBM-controlled source: *icr.io/cpopen/odm-k8s/odm*.

```console
docker pull icr.io/cpopen/odm-k8s/odm
```

# Quick reference

-	**Where to get help**:
  * [ODM Documentation](https://www.ibm.com/docs/en/odm/9.5.0?topic=manager-introducing-operational-decision)
  * [IBM Business Automation Community](https://community.ibm.com/community/user/automation/communities/community-home?CommunityKey=c0005a22-520b-4181-bfad-feffd8bdc022)

-	**Where to file issues**:  
  https://github.com/ODMDev/odm-ondocker/issues

-	**Maintained by**:  IBM ODM Team.

-	**Supported architectures**:  ([more info](https://github.com/docker-library/official-images#architectures-other-than-amd64))
 `amd64`, `ppc64le`, `s390x`, `arm64`
-	**Source of this description**:
        https://github.com/ODMDev/odm-ondocker/tree/master/standalone/dockerhub

-	**Supported Docker versions**:  
	[latest release](https://docs.docker.com/engine/release-notes/#201021) (down to Engine 28.x)

-	**Rule Designer development environment for ODM developers**:  
	Available from the [Eclipse marketplace](https://marketplace.eclipse.org/content/ibm-operational-decision-manager-developers-v95x-rule-designer)

	You install Rule Designer into [Eclipse 2024-12 (4.34)](https://www.eclipse.org/downloads/packages/release/2024-12/r). Use at least [Eclipse Modeling Tool](https://www.eclipse.org/downloads/packages/release/2024-12/r/eclipse-modeling-tools) or [Eclipse IDE for Enterprise Java and Web Developers](https://www.eclipse.org/downloads/packages/release/2024-12/r/eclipse-ide-enterprise-java-and-web-developers).
    
	Eclipse 2024-12 uses Java Development Kit (JDK) 21. You can download the JDK from [IBM Semeru Runtimes Downloads](https://developer.ibm.com/languages/java/semeru-runtimes/downloads/).

	More informations on [ODM Documentation- Installing Rule Designer](https://www.ibm.com/docs/en/odm/9.5.0?topic=950-installing-rule-designer)

-	**Sample projects**:

	Two decision services can be directly used in Decision Center when you set the SAMPLE option to true as described in the Usage section below:
	- Loan Validation Service

	This decision service validates loans based on borrower data and loan parameters. It also computes loan insurance rates.

	You can explore the decision artifacts, tests and simulations of these projects in the Business console.

	- Loan-Server Web Application

	This sample application uses rules from the Loan Validation Service to process loans.

	You can use the application to test the Loan Validation Service with parameters entered by you.


-	**Tutorials**:

	- [Getting started with ODM for Developers Docker image](https://github.com/ODMDev/odm-for-dev-getting-started)


# Overview

  The image in this repository contains IBM Operational Decision Manager for Developers based on the IBM Websphere Application Server Liberty for Developer image. See the license section below for restrictions on the use of this image. For more information about IBM Operational Decision Manager, see the [ODM Documentation](https://www.ibm.com/docs/en/odm/9.5.0?topic=manager-introducing-operational-decision) site.


  # Usage

The ODM for Developers docker image contains all of the IBM Operational Decision Manager components, so that you can evaluate the product.

> **Note**: On some operating systems like Mac OS X, you might need to increase the memory allocated to docker to be able to run the image. Allocate at least 4 GigaBytes (GB) to your docker daemon to be able to use all of the features in the docker image.

The image contains a server that is preconfigured with a database accessible through HTTP port 9060 and HTTPS port 9443.
You must accept the license before you launch the image. The license is available at the bottom of this page.
To install the product with the sample projects, you need to specify the option -e SAMPLE=true. To be able to run simulations, you need to increase the size of the memory. Use the following docker command to run the image:

```console
docker run -e LICENSE=accept -p 9060:9060 -p 9443:9443  -e SAMPLE=true icr.io/cpopen/odm-k8s/odm:9.5
```

Some decision artifacts, like simulation definitions, version history, or snapshots, cannot be exported from the Decision Center or the Decision Server instances of the Docker image. To avoid losing this data when you delete the Docker image container, store the Decision Center and the Decision Server databases outside of the ODM for Developers Docker image container, in a local mounted host volume. To do so, run the following docker command from an empty local folder:

```console
docker run -e LICENSE=accept -p 9060:9060 -p 9443:9443 -u $(id -u) -v $PWD:/config/dbdata/ -e SAMPLE=false  icr.io/cpopen/odm-k8s/odm:9.5
```

When you first run this command, it creates the .db files in your local folder. The following times, it reads and updates these files.

When the server is started, use the URL http://localhost:9060 to display a welcome page that lists all the ODM components. You can also directly access the individual components through the following URLs:

|Component|URL|Username|Password|
|:-----:|:-----:|:-----:|:-----:|
| [Decision Server console](http://localhost:9060/res) | http://localhost:9060/res |odmAdmin|odmAdmin|
| [Decision Server Runtime](http://localhost:9060/DecisionService) | http://localhost:9060/DecisionService |odmAdmin|odmAdmin|
| [Decision Center Business console]( http://localhost:9060/decisioncenter) | http://localhost:9060/decisioncenter |odmAdmin|odmAdmin|
| [Decision Runner]( http://localhost:9060/DecisionRunner) | http://localhost:9060/DecisionRunner |odmAdmin|odmAdmin|
| [Sample application]( http://localhost:9060/loan-server) | http://localhost:9060/loan-server  | | |


  # License

  The Docker files and associated scripts are licensed under [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).

  License information for the products installed within the image is as follows:
  -	[IBM Operational Decision Manager for Developers ](https://raw.githubusercontent.com/ODMDev/odm-ondocker/master/standalone/licenses/Lic_en.txt)

**Note**: The IBM Operational Decision Manager for Developers license does not permit further distribution and the terms restrict usage to a developer machine.


