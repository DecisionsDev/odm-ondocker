
This repository is the home directory of IBM Operational Decision Manager for Developers.

# Quick reference

-	**Where to get help**:   [ODMDev community](https://developer.ibm.com/odm/)

-	**Where to file issues**:  
  https://github.com/ODMDev/odm-ondocker/issues

-	**Maintained by**:   [ODMDev Community](https://github.com/ODMDev)

-	**Supported architectures**:  ([more info](https://github.com/docker-library/official-images#architectures-other-than-amd64))
 [`i386`](https://hub.docker.com/r/i386/websphere-liberty/),
-	**Source of this description**:
        https://github.com/ODMDev/odm-ondocker/tree/master/standalone/dockerhub

-	**Supported Docker versions**:  
	[latest release](https://github.com/docker/docker-ce/releases/latest) (down to 17 on a best-effort basis)

-	**Rule Designer development environment for ODM developers**:  
	[Eclipse marketplace](https://marketplace.eclipse.org/content/ibm-operational-decision-manager-developers-rule-designer)

	[latest release](https://github.com/ODMDev/ruledesigner/raw/master)

  # Overview

  The image in this repository contains IBM Operational Decision Manager for Developers based on the IBM Websphere Application Server Liberty for Developer image. See the license section below for restrictions on the use of this image. For more information about IBM Operational Decision Manager, see the [ODMDev](https://www.ibm.com/support/knowledgecenter/en/SSQP76_8.9.2/com.ibm.odm.dserver.rules.tutorials/tut_gs_topics/odm_dserver_rules_gs.html) site.


  # Usage

This image contains IBM Operational Decision Manager with all the components in a single image.
It allows you to evaluate the product.

The image contains a server that is preconfigured with a database accessible through HTTP port 9060 and HTTPS port 9443.

```console
$ docker run -e LICENSE=accept -p 9060:9060 -p 9443:9443 ibmcom/odm
```
You must accept the license before you launch the image. The license is available at the bottom of this page.

When the server is started, you can access the ODM applications with the following URLs:

|Component|URL|Username|Password|
|:-----:|:-----:|:-----:|:-----:|
| [Decision Server Console](http://localhost:9060/res) | <http://localhost:9060/res> |resAdmin|resAdmin|
| [Decision Server Runtime](http://localhost:9060/DecisionService) |<http://localhost:9060/DecisionService> |N/A|N/A|
| [Decision Center Business Console]( http://localhost:9060/decisioncenter) |  <http://localhost:9060/decisioncenter> |rtsAdmin|rtsAdmin|
| [Decision Center Enterprise Console]( http://localhost:9060/teamserver) |  <http://localhost:9060/teamserver> |rtsAdmin|rtsAdmin|
| [Decision Runner]( http://localhost:9060/DecisionRunner) |  <http://localhost:9060/DecisionRunner> |resDeployer|resDeployer|


  # License

  The Docker files and associated scripts are licensed under [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).

  License information for the products installed within the image is as follows:
  -	[IBM Operational Decision Manager for Developers ](https://raw.githubusercontent.com/ODMDev/odm-ondocker/master/standalone/licenses/Lic_en.txt)

**Note**: The IBM Operational Decision Manager for Developers license does not permit further distribution and the terms restrict usage to a developer machine.
