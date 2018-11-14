
This repository is the home directory of IBM Operational Decision Manager for Developers.

# Quick reference

-	**Video**:
[![ODM overview](http://img.youtube.com/vi/ccdFtyy34x8/0.jpg)](http://www.youtube.com/watch?feature=player_embedded&v=ccdFtyy34x8)


-	**Where to get help**:
  * [ODM Documentation](https://www.ibm.com/support/knowledgecenter/en/SSQP76_8.10.0/com.ibm.odm.distrib.overview/topics/tpc_dmov_intro_intro.html)
  * [ODM Developer Center community](https://developer.ibm.com/odm/)

-	**Where to file issues**:  
  https://github.com/ODMDev/odm-ondocker/issues

-	**Maintained by**:  IBM ODM Team.

-	**Supported architectures**:  ([more info](https://github.com/docker-library/official-images#architectures-other-than-amd64))
 `amd64`, `ppc64le`, `s390x`
-	**Source of this description**:
        https://github.com/ODMDev/odm-ondocker/tree/master/standalone/dockerhub

-	**Supported Docker versions**:  
	[latest release](https://github.com/docker/docker-ce/releases/latest) (down to 17 on a best-effort basis)

-	**Rule Designer development environment for ODM developers**:  
	Available from the [Eclipse marketplace](https://marketplace.eclipse.org/content/ibm-operational-decision-manager-developers-rule-designer)

	Use [Eclipse v4.7.3](http://www.eclipse.org/downloads/packages/release/oxygen/3a). The update site is https://github.com/ODMDev/ruledesigner/tree/8.10.0/p2
	
-	**Samples and tutorials**:

	TBD[Getting started with ODM for Developers Docker image](https://github.com/ODMDev/odm-for-dev-getting-started)
	
	[Getting started with decision modeling](https://www.ibm.com/support/knowledgecenter/en/SSQP76_8.10.0/com.ibm.odm.dcenter.tutorials/tutorials_topics/odm_dc_mod_int.html)
	
	[Debugging a decision service in Rule Designer](https://www.ibm.com/support/knowledgecenter/en/SSQP76_8.10.0/com.ibm.odm.cloud.tutorials/tut_cloud_rd_debug_kctopics/odm_cloud_debug_tut.html)
	
	[Loan Validation sample files](https://github.com/ODMDev/odm-on-cloud-debug)
	
	[Miniloan sample files](https://github.com/ODMDev/odm-on-cloud-getting-started)

# Overview

  The image in this repository contains IBM Operational Decision Manager for Developers based on the IBM Websphere Application Server Liberty for Developer image. See the license section below for restrictions on the use of this image. For more information about IBM Operational Decision Manager, see the [ODM Documentation](https://www.ibm.com/support/knowledgecenter/en/SSQP76_8.10.0/com.ibm.odm.distrib.overview/topics/tpc_dmov_intro_intro.html) site.


  # Usage

This image contains IBM Operational Decision Manager with all the components in a single image.
It allows you to evaluate the product.

The image contains a server that is preconfigured with a database accessible through HTTP port 9060 and HTTPS port 9443.

```console
$ docker run -e LICENSE=accept -p 9060:9060 -p 9443:9443 ibmcom/odm
```
You must accept the license before you launch the image. The license is available at the bottom of this page.

When the server is started, you can display a welcome page that lists all the ODM applications by accessing the URL http://localhost:9060. You can also directly access the individual applications through the following URLs:

|Component|URL|Username|Password|
|:-----:|:-----:|:-----:|:-----:|
| [Decision Server Console](http://localhost:9060/res) | <http://localhost:9060/res> |odmAdmin|odmAdmin|
| [Decision Server Runtime](http://localhost:9060/DecisionService) |<http://localhost:9060/DecisionService> |odmAdmin|odmAdmin|
| [Decision Center Business Console]( http://localhost:9060/decisioncenter) |  <http://localhost:9060/decisioncenter> |odmAdmin|odmAdmin|
| [Decision Center Enterprise Console]( http://localhost:9060/teamserver) |  <http://localhost:9060/teamserver> |odmAdmin|odmAdmin|
| [Decision Runner]( http://localhost:9060/DecisionRunner) |  <http://localhost:9060/DecisionRunner> |odmAdmin|odmAdmin|


  # License

  The Docker files and associated scripts are licensed under [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).

  License information for the products installed within the image is as follows:
  -	[IBM Operational Decision Manager for Developers ](https://raw.githubusercontent.com/ODMDev/odm-ondocker/master/standalone/licenses/Lic_en.txt)

**Note**: The IBM Operational Decision Manager for Developers license does not permit further distribution and the terms restrict usage to a developer machine.
