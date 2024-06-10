# Updating ODM Docker Images with Latest CVE Fixes

## Introduction
IBM is committed to providing monthly updates for its images, but if you want to update them more frequently, this method allows you to do so on your own.

This guide will walk you through the process of updating your ODM Docker images to ensure they are protected against known security vulnerabilities and Common Vulnerabilities and Exposures (CVEs). Regularly updating your Docker images is crucial to maintaining a secure and reliable containerized environment.

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Preparing the Environment](#2-preparing-the-environment)
3. [Updating Docker Images](#3-updating-docker-images)
   - [a. Build the Images](#a-build-the-images)
   - [b. Optional: Push to Your Target Registry](#b-optional-push-to-your-target-registry)
4. [Best Practices](#best-practices)
5. [Conclusion](#conclusion)
   
## 1. Prerequisites

Before you start, make sure you have the following prerequisites in place:

- Docker installed on your system
- Docker compose installed on your system
- Access to the the IBM Entitled Registry 
- Familiarity with the Docker command-line interface (CLI)

## 2. Preparing the Environment

To gain access to the ODM material, you will need an IBM entitlement key for downloading images from the IBM Entitled Registry.

   1. Sign in to the [MyIBM Container Software Library](https://myibm.ibm.com/products-services/containerlibrary) using your IBMid and associated password for the entitled software.
   2. On the Container software library tile, ensure your entitlement by navigating to the View library page. Then proceed to obtain the entitlement key.
   3. Next, use this key to log in to Docker as follows:

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
export SOURCETAG=9.0.0.0-amd64
export TARGETREGISTRY=myrepo
export TARGETTAG=9.0.0.0-amd64
docker compose build
```

Change the values according to the ODM Version and your targeted environment.

### b. Optional: Push to Your Target Registry

If you want to push the updated images to your target registry, follow these steps:

1. Log in to your targeted registry.
2. Push your images using the following command. Make sure to modify the values according to your specific setup:

```bash
export SOURCEREGISTRY=cp.icr.io/cp/cp4a/odm
export SOURCETAG=9.0.0.0-amd64
export TARGETREGISTRY=myrepo
export TARGETTAG=9.0.0.0-amd64
docker compose push
```

## Best Practices

To ensure a secure and efficient process of updating Docker images, consider the following best practices:

- Implement automation: Use continuous integration/continuous deployment (CI/CD) pipelines to automate the scanning and updating of Docker images.
- Regularly monitor CVE databases and subscribe to security mailing lists for timely updates.
- Maintain a versioning strategy for your Docker images to keep track of updates and changes.
- Secure your container registry with access controls and policies to prevent unauthorized access.

## Conclusion

By following the steps outlined in this guide and adopting best practices, you can effectively update your Docker images with the latest OS-related CVE fixes ensuring the security and stability of your containerized applications. Regularly checking for vulnerabilities and staying up-to-date is crucial in the ever-evolving world of container security.

Feel free to customize and expand upon this guide to fit your specific needs and environment.
