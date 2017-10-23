# IBM-ODM-Docker
IBM Operational Decision Manager on Docker.

 
[![Build Status](https://travis-ci.org/ODMDev/odm-ondocker.svg?branch=master)](https://travis-ci.org/ODMDev/odm-ondocker)
[![GitHub release](https://img.shields.io/github/release/ODMDev/odm-ondocker.svg)](https://github.com/ODMDev/odm-ondocker/releases)
[![GitHub last commit (branch)](https://img.shields.io/github/last-commit/ODMDev/odm-ondocker/dev.svg)](https://github.com/ODMDev/odm-ondocker)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
<p align="center">
  <a href="https://join.slack.com/t/odmdev/shared_invite/enQtMjU0NzIwMjM1MTg0LTQyYTMzNGQ4NzJkMDYxMDU5MDRmYTM4MjcxN2RiMzNmZWZmY2UzYzRhMjk0N2FmZjU2YzJlMTRmN2FhZDY4NmQ">
        Follow us on slack
        <br>
        <img src="https://a.slack-edge.com/436da/marketing/img/meta/favicon-32.png">
  </a>
</p>


#  Deploy IBM Operational Decision Manager Standard on Docker from Dev to Production 

This repository centralizes the material to deploy IBM Operational Decision Manager Standard in Docker. 
It includes Docker files and Docker compose descriptors. Docker files are used to build images of ODM runtimes. And docker-compose descriptor can be used to group this build, push to your repository and run your topology from Development to production.

[IBM ODM](https://www.ibm.com/support/knowledgecenter/SSQP76_8.9.0/welcome/kc_welcome_odmV.html) is a decisioning platform to automate your business policies. Business rules are used at the heart of the platform to implement decision logic on a business vocabulary and run it as web decision services.


![Flow](docs/images/Fig1.png)

In addition to this repository about ODM on Docker, there is a dedicated repository to deploy [ODM on Kubernetes](https://github.com/PierreFeillet/IBM-ODM-Kubernetes/?cm_mc_uid=48109996374214948388780&cm_mc_sid_50200000=1497520790).
## Deploying ODM Rules in the following environments
- [ODM Standalone Docker image](docs/README_standalone.md): Explain how to build one docker image that contain all the ODM Components. (For Development purpose)
- [ODM Standard Docker topology](docs/README_standard.md): Explain how to build and instanciate one docker image per ODM Components. (For Pre-Production purpose) 
- [ODM Clustered Docker topology](docs/README_cluster.md): Explain how to build and instanciate one docker image per ODM Components with possibility to scale the number of container. (For Production purpose) 
 
# References
- [ODM on Kubernetes](https://github.com/PierreFeillet/IBM-ODM-Kubernetes/?cm_mc_uid=48109996374214948388780&cm_mc_sid_50200000=1497520790).
- [DevWorks article : Deploy an IBM Operational Decision Manager topology with Docker Compose ](https://www.ibm.com/developerworks/library/mw-1612-grateau-trs/1612-grateau.html)
- [IBM Operational Decision Manager Developer Center](https://developer.ibm.com/odm/)

# Issues and contributions

For issues relating specifically to the Dockerfiles and scripts, please use the [GitHub issue tracker](https://github.com/lgrateau/odm-ondocker/issues). For more general issue relating to IBM Operational Decision Manager you can [get help](https://developer.ibm.com/odm/home/connect/) through the ODMDev community or, if you have production licenses for Operational Decision Manager, via the usual support channels. We welcome contributions following [our guidelines](https://github.com/lgrateau/odm-ondocker/blob/master/CONTRIBUTING.md).



# License
[Apache 2.0](LICENSE)

# Notice
© Copyright IBM Corporation 2017.
