# Updating ODM Docker Images with Latest CVE Fixes

## Introduction

This guide will walk you through the process of updating your ODM Docker images to ensure they are protected against known security vulnerabilities and Common Vulnerabilities and Exposures (CVEs). Regularly updating your Docker images is crucial to maintaining a secure and reliable containerized environment.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Identifying Vulnerabilities](#identifying-vulnerabilities)
3. [Updating Docker Images](#updating-docker-images)
4. [Best Practices](#best-practices)
5. [Conclusion](#conclusion)

## 1. Prerequisites

Before you start, make sure you have the following prerequisites in place:

- Docker installed on your system
- Docker compose installed on your system
- Access to the Docker Hub or your private container registry
- Familiarity with the Docker command-line interface (CLI)

## 2. Preping the environment

To get access to the ODM material, you must have an IBM entitlement key to pull the images from the IBM Entitled Registry.

Log in to [MyIBM Container Software Library](https://myibm.ibm.com/products-services/containerlibrary) with the IBMid and password that are associated with the entitled software.

In the Container software library tile, verify your entitlement on the View library page, and then go to Get entitlement key to retrieve the key.

Then docker login with that informations:
```bash
docker login cp.icr.io -u cp -p <REGISTRYKEY>
```


## 3. Updating Docker Images

### a. Build the Images

To update your Docker images, follow these steps:

1. Download or clone this GitHub repository.
2. Navigate to the `contrib/update-images` directory.
3. Build the images using the following Docker Compose command. Make sure to change the values according to the ODM Version and your targeted environment:

```bash
export SOURCEREGISTRY=cp.icr.io/cp/cp4a/odm
export SOURCETAG=8.12.0.0-amd64
export TARGETREGISTRY=myrepo
export TARGETTAG=8.12.0.0-amd64
docker compose build
```

Change the values according to the ODM Version and your targeted environment.

### b. Optional: Push to Your Target Registry

If you want to push the updated images to your target registry, follow these steps:

1. Log in to your targeted registry.

2. Push your images using the following command. Make sure to modify the values according to your specific setup:

```bash
export SOURCEREGISTRY=cp.icr.io/cp/cp4a/odm
export SOURCETAG=8.12.0.0-amd64
export TARGETREGISTRY=myrepo
export TARGETTAG=8.12.0.0-amd64
docker compose push

## Best Practices

To ensure a secure and efficient process of updating Docker images, consider the following best practices:

- Implement automation: Use continuous integration/continuous deployment (CI/CD) pipelines to automate the scanning and updating of Docker images.
- Regularly monitor CVE databases and subscribe to security mailing lists for timely updates.
- Maintain a versioning strategy for your Docker images to keep track of updates and changes.
- Secure your container registry with access controls and policies to prevent unauthorized access.

## Conclusion

By following the steps outlined in this guide and adopting best practices, you can effectively update your Docker images with the latest CVE fixes, ensuring the security and stability of your containerized applications. Regularly checking for vulnerabilities and staying up-to-date is crucial in the ever-evolving world of container security.

Feel free to customize and expand upon this guide to fit your specific needs and environment.
