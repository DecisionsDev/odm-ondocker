# IBM-ODM-Docker
IBM Operational Decision Manager on Docker

[![Build and test](https://github.com/DecisionsDev/odm-ondocker/actions/workflows/build-and-test.yml/badge.svg?branch=vnext-release)](https://github.com/DecisionsDev/odm-ondocker/actions/workflows/build-and-test.yml) ![GitHub last commit](https://img.shields.io/github/last-commit/lgrateau/odm-ondocker)

[![GitHub release](https://img.shields.io/github/release/DecisionsDev/odm-ondocker.svg)](https://github.com/DecisionsDev/odm-ondocker/releases)


[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
<p align="center">
  <a href="https://join.slack.com/t/odmdev/shared_invite/enQtMjU0NzIwMjM1MTg0LTQyYTMzNGQ4NzJkMDYxMDU5MDRmYTM4MjcxN2RiMzNmZWZmY2UzYzRhMjk0N2FmZjU2YzJlMTRmN2FhZDY4NmQ">
        Follow us on slack
        <br>
        <img src="https://a.slack-edge.com/436da/marketing/img/meta/favicon-32.png">
  </a>
</p>


#  Deploy IBM Operational Decision Manager  on Docker from Dev to Production

This repository centralizes the material to deploy IBM Operational Decision Manager in Docker.
It includes Docker files and Docker compose descriptors. Docker files are used to build images of ODM runtimes. And docker-compose descriptor can be used to group this build, push to your repository and run your topology from Development to production.

[IBM ODM](https://www.ibm.com/docs/en/odm/8.11.0) is a decisioning platform to automate your business policies. Business rules are used at the heart of the platform to implement decision logic on a business vocabulary and run it as web decision services.


![Flow](docs/images/Architecture.png "Architecture")

In addition to this repository about ODM on Docker, there is a dedicated repository to deploy [ODM on Kubernetes](https://github.com/PierreFeillet/IBM-ODM-Kubernetes/?cm_mc_uid=48109996374214948388780&cm_mc_sid_50200000=1497520790) and the [IBM Operational Decision Manager for Developers docker image](https://hub.docker.com/r/ibmcom/odm/) in dockerhub.

## Deploying ODM Rules in the following environments
This documentations applies to Operational Decision Management Standard V8.11.x and to earlier versions up to v8.8.x.
- [ODM Standalone Docker image](docs/README_standalone.md): Explain how to build one docker image that contain all the ODM Components. (For Development purpose)
- [ODM Standard Docker topology](docs/README_standard.md): Explain how to build and instanciate one docker image per ODM Components. (For Pre-Production purpose)
- [ODM Clustered Docker topology](docs/README_cluster.md): Explain how to build and instanciate one docker image per ODM Components with possibility to scale the number of container. (For Production purpose)
- [ODM integration with Business Automation Intelligence](contrib/bai-singlenode/README.md): Explain how to demonstrate ODM with BAI for Server with minimal effort.

# References
- [DevWorks article : Deploy an IBM Operational Decision Manager topology with Docker Compose ](https://www.ibm.com/developerworks/library/mw-1612-grateau-trs/1612-grateau.html)
- [IBM Business Automation Community](https://community.ibm.com/community/user/automation/communities/community-home?CommunityKey=c0005a22-520b-4181-bfad-feffd8bdc022)

# Issues and contributions

For issues relating specifically to the Dockerfiles and scripts, please use the [GitHub issue tracker](https://github.com/ODMDev/odm-ondocker/issues). For more general issue relating to IBM Operational Decision Manager you can [get help](https://community.ibm.com/community/user/automation/communities/community-home?CommunityKey=c0005a22-520b-4181-bfad-feffd8bdc022) through the ODM community or, if you have production licenses for Operational Decision Manager, via the usual support channels. We welcome contributions following [our guidelines](https://github.com/ODMDev/odm-ondocker/blob/master/CONTRIBUTING.md).

# License tracking with IBM License Service

Refer to the [Add IBM License Metering annotations](README-license-annotations.md) page to enable license tracking in IBM License Service.

# License
[Apache 2.0](LICENSE)

# Notice
© Copyright IBM Corporation 2018.
