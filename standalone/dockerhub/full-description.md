
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
	

-	**Sample projects**:

	Two decision services can be directly used in Decision Center when you set the SAMPLE option to true; see the Usage section on this page:
	- Loan Validation Service
	
	This decision service validates loans based on borrower data and loan parameters. It also computes loan insurance rates.
	
	- Shipment Pricing
	
	This decision model service computes shipping prices based on data that includes distance, size, weight, and pick-up and drop-off points.
        	
	You can explore the decision artifacts, tests and simulations of these projects in the Business console.

	
-	**Tutorials**:

	- [Getting started with ODM for Developers Docker image](https://github.ibm.com/ibm-odm/odm-for-dev-gettingstarted)
	
	- [Creating a decision service in Rule Designer](http://engtest01w.fr.eurolabs.ibm.com:9190/support/knowledgecenter/SS7J8H/com.ibm.odm.cloud.tutorials/tut_cloud_ds_topics/odm_cloud_dservice_tut.html). For this tutorial, you need some knowledge of Java and the Eclipse workspaces, perspectives, and views. The following instructions supersede the prerequisites given in the tutorial documentation:
	  
	    - Get Rule Designer from the Eclipse marketplace, as indicated at the beginning of this page.
	    - Download the Miniloan sample project from the https://github.ibm.com/ibm-odm/odm-for-dev-gettingstarted GitHub repository by clicking 'Clone or download' and then 'Download ZIP'.
	    - Extract its contents to a new directory. The tutorial later refers to this directory as <InstallDir>/miniloanservice-projects. The size of the download file is about 13 KB.
	    - For Decision Server console and Decision Center Business console, use the URLs and the users/passwords provided in the table below on this page.  
	
	- [Getting started with decision modeling in the Business console](http://engtest01w.fr.eurolabs.ibm.com:9190/support/knowledgecenter/SSQP76_8.10.0/com.ibm.odm.dcenter.tutorials/tutorials_topics/odm_dc_mod_int.html). For Decision Center Business console, use the URL and the user/password provided in the table below on this page.


# Overview

  The image in this repository contains IBM Operational Decision Manager for Developers based on the IBM Websphere Application Server Liberty for Developer image. See the license section below for restrictions on the use of this image. For more information about IBM Operational Decision Manager, see the [ODM Documentation](https://www.ibm.com/support/knowledgecenter/en/SSQP76_8.10.0/com.ibm.odm.distrib.overview/topics/tpc_dmov_intro_intro.html) site.


  # Usage

This image contains IBM Operational Decision Manager with all the components in a single image.
It allows you to evaluate the product.

The image contains a server that is preconfigured with a database accessible through HTTP port 9060 and HTTPS port 9443.
You must accept the license before you launch the image. The license is available at the bottom of this page.
To install with the sample projects, you need to specify the option -e SAMPLE=true. To be able to run simulations, you need to increase the size of the memory:

```console
$ docker run -e LICENSE=accept -p 9060:9060 -p 9443:9443  -m 2048M --memory-reservation 2048M  -e SAMPLE=true ibmcom/odm:8.10.0.0
```

Some decision artifacts, like simulation definitions, version history, or snapshots, cannot be exported from the Decision Center or the Decision Server instances of the Docker image. To avoid losing this data when you delete the Docker image container, you are recommended to store the Decision Center and the Decision Server databases outside the ODM for Developers Docker image container, in a local mounted host volume. To do so, run the command:
 
 ```console
  docker run -e LICENSE=accept  -m 2048M --memory-reservation 2048M -p 9060:9060 -p 9443:9443 -v $PWD:/config/dbdata/ -e SAMPLE=false  ibmcom/odm:8.10.0.0
```
 When you first run this command, it creates the .db files in your local directory. The following times, it reads and updates these files.

When the server is started, use the URL http://localhost:9060 to display a welcome page that lists all the ODM components. You can also directly access the individual components through the following URLs:

|Component|URL|Username|Password|
|:-----:|:-----:|:-----:|:-----:|
| [Decision Server console](http://localhost:9060/res) | <http://localhost:9060/res> |odmAdmin|odmAdmin|
| [Decision Server Runtime](http://localhost:9060/DecisionService) |<http://localhost:9060/DecisionService> |odmAdmin|odmAdmin|
| [Decision Center Business console]( http://localhost:9060/decisioncenter)) |  <http://localhost:9060/decisioncenter> |odmAdmin|odmAdmin|
| [Decision Center Enterprise console]( http://localhost:9060/teamserver) |  <http://localhost:9060/teamserver> |odmAdmin|odmAdmin|
| [Decision Runner]( http://localhost:9060/DecisionRunner) |  <http://localhost:9060/DecisionRunner> |odmAdmin|odmAdmin|


  # License

  The Docker files and associated scripts are licensed under [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).

  License information for the products installed within the image is as follows:
  -	[IBM Operational Decision Manager for Developers ](https://raw.githubusercontent.com/ODMDev/odm-ondocker/master/standalone/licenses/Lic_en.txt)

**Note**: The IBM Operational Decision Manager for Developers license does not permit further distribution and the terms restrict usage to a developer machine.
