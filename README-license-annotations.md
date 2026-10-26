# Add IBM License Metering annotations to custom ODM containers

License annotations let you track usage based on the limits defined on the container, rather than on the underlying machine. You configure the container to be deployed with specific annotations that the IBM® License Service then uses to track usage.

The IBM License Service needs to be installed on the Kubernetes cluster where the IBM ODM containers (predefined or custom) are deployed to track usage. Further information regarding the supported environments and installation instructions can be found on the [Installing License Service without Operator Lifecycle Manager documentation](https://www.ibm.com/docs/en/cloud-paks/foundational-services/4.x?topic=ilsfpcr-installing-license-service-without-operator-lifecycle-manager-olm).

The IBM License Service processes pod annotations to track licenses. Therefore product teams must use specific metering annotations in the `spec.template.metadata.annotations` section of their Kubernetes pod template for custom ODM containers, similarly to what is provided for the predefined ODM containers.

Based on your deployment type, use the following annotations:
- [Add IBM License Metering annotations to custom ODM containers](#add-ibm-license-metering-annotations-to-custom-odm-containers)
  - [Guidance](#guidance)
  - [IBM ODM on Kubernetes (Production)](#ibm-odm-on-kubernetes-production)
  - [IBM ODM on Kubernetes (Non-Production)](#ibm-odm-on-kubernetes-non-production)
    - [Example for ODM on Kubernetes](#example-for-odm-on-kubernetes)
  - [Use IBM Cloud Pak for Business Automation / IBM Decision Intelligence Enterprise Edition license](#use-ibm-cloud-pak-for-business-automation--ibm-decision-intelligence-enterprise-edition-license)
    - [Cloud Pak for Business Automation (Production)](#cloud-pak-for-business-automation-production)
    - [Cloud Pak for Business Automation (Non-Production)](#cloud-pak-for-business-automation-non-production)
      - [Example for CP4BA](#example-for-cp4ba)
    - [Decision Intelligence Enterprise Edition (Production)](#decision-intelligence-enterprise-edition-production)
    - [Decision Intelligence Enterprise Edition (Non-Production)](#decision-intelligence-enterprise-edition-non-production)
      - [Example for DIEE](#example-for-diee)

The annotations below are defined for ODM version 9.6, but you can also use them for ODM v8.10.5.1 by replacing **productVersion** value with "8.10.5.1".

## Guidance

**containername** must be set to the name of the container as set in `spec.template.spec.containers.name` parameter of your [pod template](https://kubernetes.io/docs/concepts/workloads/pods/#pod-templates) except for *decisionServerConsole* container where it must be set to **""**, since *decisionServerConsole* container is not charged.

## IBM ODM on Kubernetes (Production)

- Use the following annotations for all the containers:

  ```yaml
  spec:
    template:
      metadata:
        annotations:
          productName: "IBM Operational Decision Manager"
          productID: "b1a07d4dc0364452aa6206bb6584061d"
          productVersion: "9.6.0.0"
          productMetric: "PROCESSOR_VALUE_UNIT"
          productChargedContainers: <containername>
  ```
> [!NOTE]
> - The `<containername>` parameter should be left empty for the Decision Server console because the `decisionServerConsole` container is not charged.
> - You can put `decisioncenter`, `decisionserverruntime` or `decisionrunner` for the other components.

- For the Decision Runner container with a nonproduction license, use the following annotations:

  ```yaml
  spec:
    template:
      metadata:
        annotations:
          productName: "IBM Operational Decision Manager - Non Prod"
          productID: "e32af5770e06427faae142993c691048"
          productVersion: "9.6.0.0"
          productMetric: "PROCESSOR_VALUE_UNIT"
          productChargedContainers: <containername>
  ```

> [!NOTE]
> - `Decision Runner` container which is used for testing and simulation, is usually charged in non-production mode. However, it can be changed to production mode if you have only a production license.

## IBM ODM on Kubernetes (Non-Production)

- Use the following annotations for all the containers:

  ```yaml
  spec:
    template:
      metadata:
        annotations:
          productName: "IBM Operational Decision Manager - Non Prod"
          productID: "e32af5770e06427faae142993c691048"
          productVersion: "9.6.0.0"
          productMetric: "PROCESSOR_VALUE_UNIT"
          productChargedContainers: <containername>
  ```

### Example for ODM on Kubernetes

Decision Server Runtime Production example:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-odm-decisionserverruntime
  ...
spec:
  ...
  template:
    metadata:
      ...
      annotations:
        productName: "IBM Operational Decision Manager"
        productID: "b1a07d4dc0364452aa6206bb6584061d"
        productVersion: "9.6.0.0"
        productMetric: "PROCESSOR_VALUE_UNIT"
        productChargedContainers: my-odm-decisionserverruntime
    spec:
      ...

      containers:
      - name: my-odm-decisionserverruntime
        image: my-repo/my-odm-decisionserverruntime:9.6.0.0-amd64
        ...
```

## Use IBM Cloud Pak for Business Automation / IBM Decision Intelligence Enterprise Edition license
You can install Operational Decision Manager on Certified Kubernetes by using a license for either IBM Cloud Pak for Business Automation or IBM Decision Intelligence Enterprise Edition.

### Cloud Pak for Business Automation (Production)

- Use the following annotations for all the containers:

  ```yaml
  spec:
    template:
      metadata:
        annotations:
          cloudpakName: "IBM Cloud Pak for Business Automation"
          cloudpakId: "94a9c8c358bb43ba8fbdea62e7e166a5"
          cloudpakVersion: "26.0.0"
          productName: "Operational Decision Manager Containers - CP4BA"
          productID: "cfdbd71c64094971a70b6985df6b1e93"
          productCloudpakRatio: "1:5"
          productMetric: "VIRTUAL_PROCESSOR_CORE"
          productVersion: "26.0.0"
          productChargedContainers: <containername>
  ```
> [!NOTE]
> - The `<containername>` parameter should be left empty for the Decision Server console because the `decisionServerConsole` container is not charged.
> - You can put `decisioncenter`, `decisionserverruntime` or `decisionrunner` for the other components.

- For the Decision Runner container with a `nonproduction` license, use the following annotations:

  ```yaml
  spec:
    template:
      metadata:
        annotations:
          cloudpakName: "IBM Cloud Pak for Business Automation"
          cloudpakId: "94a9c8c358bb43ba8fbdea62e7e166a5"
          cloudpakVersion: "26.0.0"
          productName: "Operational Decision Manager Containers - CP4BA - Non Prod"
          productVersion: "26.0.0"
          productID: "d803dec7647d48d39f6803e077d36080"
          productMetric: "VIRTUAL_PROCESSOR_CORE"
          productCloudpakRatio: "2:5"
          productChargedContainers: "decisionrunner"
  ```
> [!NOTE]
> - `Decision Runner` container which is used for testing and simulation, is usually charged in non-production mode. However, it can be changed to production mode if you have only a production license.

### Cloud Pak for Business Automation (Non-Production)

- Use the following annotations for all the containers:

  ```yaml
  spec:
    template:
      metadata:
        annotations:
          cloudpakName: "IBM Cloud Pak for Business Automation"
          cloudpakId: "94a9c8c358bb43ba8fbdea62e7e166a5"
          cloudpakVersion: "26.0.0"
          productName: "Operational Decision Manager Containers - CP4BA - Non Prod"
          productVersion: "26.0.0"
          productID: "d803dec7647d48d39f6803e077d36080"
          productMetric: "VIRTUAL_PROCESSOR_CORE"
          productCloudpakRatio: "2:5"
          productChargedContainers: <containername>
  ```
> [!NOTE]
> - The `<containername>` parameter should be left empty for the Decision Server console because the `decisionServerConsole` container is not charged.
> - You can put `decisioncenter`, `decisionserverruntime` or `decisionrunner` for the other components.

#### Example for CP4BA

The following example shows the container annotations for a production Decision Server runtime with CP4BA license:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-odm-decisionserverruntime
  ...
spec:
  ...
  template:
    metadata:
      ...
      annotations:
        cloudpakName: "IBM Cloud Pak for Business Automation"
        cloudpakId: "94a9c8c358bb43ba8fbdea62e7e166a5"
        cloudpakVersion: "26.0.0"
        productName: "Operational Decision Manager Containers - CP4BA"
        productID: "cfdbd71c64094971a70b6985df6b1e93"
        productCloudpakRatio: "1:5"
        productMetric: "VIRTUAL_PROCESSOR_CORE"
        productVersion: "26.0.0"
        productChargedContainers: my-odm-decisionserverruntime
    spec:
      ...

      containers:
      - name: my-odm-decisionserverruntime
        image: my-repo/my-odm-decisionserverruntime:9.6.0.0-amd64
        ...
```

### Decision Intelligence Enterprise Edition (Production)

- Use the following DIEE annotations for all the containers:

  ```yaml
  spec:
    template:
      metadata:
        annotations:
          cloudpakName: "IBM Decision Intelligence Enterprise Edition"
          cloudpakId: "c8d689d74ff2492db83b8f9c1e8447d0"
          cloudpakVersion: "26.0.0"
          productName: "Operational Decision Manager Containers - DIEE"
          productID: "c2a36ffa96f94e5092159e5a8736602d"
          productCloudpakRatio: "1:5"
          productMetric: "VIRTUAL_PROCESSOR_CORE"
          productVersion: "26.0.0"
          productChargedContainers: <containername>
  ```
> [!NOTE]
> - The `<containername>` parameter should be left empty for the Decision Server console because the `decisionServerConsole` container is not charged.
> - You can put `decisioncenter`, `decisionserverruntime` or `decisionrunner` for the other components.

- For the Decision Runner container with a nonproduction license, use the following annotations:

  ```yaml
  spec:
    template:
      metadata:
        annotations:
          cloudpakName: "IBM Decision Intelligence Enterprise Edition"
          cloudpakId: "c8d689d74ff2492db83b8f9c1e8447d0"
          cloudpakVersion: "26.0.0"
          productName: "Operational Decision Manager Containers - DIEE - Non Prod"
          productVersion: "26.0.0"
          productID: "bf8e69fce9f74260b88d2f1042928439"
          productMetric: "VIRTUAL_PROCESSOR_CORE"
          productCloudpakRatio: "2:5"
          productChargedContainers: "decisionrunner"
  ```
> [!NOTE]
> - `Decision Runner` container which is used for testing and simulation, is usually charged in non-production mode. However, it can be changed to production mode if you have only a production license.

### Decision Intelligence Enterprise Edition (Non-Production)

- Use the following DIEE non-production annotations for all the containers:

  ```yaml
  spec:
    template:
      metadata:
        annotations:
          cloudpakName: "IBM Decision Intelligence Enterprise Edition"
          cloudpakId: "c8d689d74ff2492db83b8f9c1e8447d0"
          cloudpakVersion: "26.0.0"
          productName: "Operational Decision Manager Containers - DIEE - Non Prod"
          productVersion: "26.0.0"
          productID: "bf8e69fce9f74260b88d2f1042928439"
          productMetric: "VIRTUAL_PROCESSOR_CORE"
          productCloudpakRatio: "2:5"
          productChargedContainers: <containername>
  ```

> [!NOTE]
> - The `<containername>` parameter should be left empty for the Decision Server console because the `decisionServerConsole` container is not charged.
> - You can put `decisioncenter`, `decisionserverruntime` or `decisionrunner` for the other components.

#### Example for DIEE

The following example shows the container annotations for a production Decision Server runtime with DIEE license:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-odm-decisionserverruntime
  ...
spec:
  ...
  template:
    metadata:
      ...
      annotations:
        cloudpakName: "IBM Decision Intelligence Enterprise Edition"
        cloudpakId: "c8d689d74ff2492db83b8f9c1e8447d0"
        cloudpakVersion: "26.0.0"
        productName: "Operational Decision Manager Containers - DIEE"
        productID: "c2a36ffa96f94e5092159e5a8736602d"
        productCloudpakRatio: "1:5"
        productMetric: "VIRTUAL_PROCESSOR_CORE"
        productVersion: "26.0.0"
        productChargedContainers: my-odm-decisionserverruntime
    spec:
      ...

      containers:
      - name: my-odm-decisionserverruntime
        image: my-repo/my-odm-decisionserverruntime:9.6.0.0-amd64
        ...
```
