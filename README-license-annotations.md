# Add IBM License Metering annotations to custom ODM containers

License annotations let you track usage based on the limits defined on the container, rather than on the underlying machine. You configure the container to be deployed with specific annotations that the IBM® License Service then uses to track usage.

The IBM License Service needs to be installed on the Kubernetes cluster where the IBM ODM containers (predefined or custom) are deployed to track usage. Further information regarding the supported environments and installation instructions can be found on the [Installing License Service without Operator Lifecycle Manager documentation](https://www.ibm.com/docs/en/cloud-paks/foundational-services/4.12.0?topic=ilsfpcr-installing-license-service-without-operator-lifecycle-manager-olm).


The IBM License Service processes pod annotations to track licenses. Therefore product teams must use specific metering annotations in the `spec.template.metadata.annotations` section of their Kubernetes pod template for custom ODM containers, similarly to what is provided for the predefined ODM containers

Based on your deployment type, use the following annotations:
- [Add IBM License Metering annotations to custom ODM containers](#add-ibm-license-metering-annotations-to-custom-odm-containers)
  - [Guidance](#guidance)
  - [IBM ODM on Kubernetes (Production)](#ibm-odm-on-kubernetes-production)
  - [IBM ODM on Kubernetes (Non-Production)](#ibm-odm-on-kubernetes-non-production)
  - [Example](#example)

The annotations below are defined for ODM version 9.5, but you can also use them for ODM v8.10.5.1 by replacing **productVersion** value with "8.10.5.1".

## Guidance

**containername** must be set to the name of the container as set in `spec.template.spec.containers.name` parameter of your [pod template](https://kubernetes.io/docs/concepts/workloads/pods/#pod-templates) except for *decisionServerConsole* container where it must be set to **""**, since *decisionServerConsole* container is not charged.


## IBM ODM on Kubernetes (Production)

- For all containers except decision-runner:

  ```yaml
  spec:
    template:
      metadata:
        annotations:
          productName: "IBM Operational Decision Manager"
          productID: "b1a07d4dc0364452aa6206bb6584061d"
          productVersion: "9.5.0.0"
          productMetric: "PROCESSOR_VALUE_UNIT"
          productChargedContainers: <containername>
  ```

- For decision-runner container:

  ```yaml
  spec:
    template:
      metadata:
        annotations:
          productName: "IBM Operational Decision Manager - Non Prod"
          productID: "e32af5770e06427faae142993c691048"
          productVersion: "9.5.0.0"
          productMetric: "PROCESSOR_VALUE_UNIT"
          productChargedContainers: <containername>
  ```

  > **Note:** *Decision Runner* container is always charged in non-production mode

## IBM ODM on Kubernetes (Non-Production)

```yaml
spec:
  template:
    metadata:
      annotations:
        productName: "IBM Operational Decision Manager - Non Prod"
        productID: "e32af5770e06427faae142993c691048"
        productVersion: "9.5.0.0"
        productMetric: "PROCESSOR_VALUE_UNIT"
        productChargedContainers: <containername>
```

## Example

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
        productVersion: "9.5.0.0"
        productMetric: "PROCESSOR_VALUE_UNIT"
        productChargedContainers: my-odm-decisionserverruntime
    spec:
      ...

      containers:
      - name: my-odm-decisionserverruntime
        image: my-repo/my-odm-decisionserverruntime:9.5.0.0-amd64
        ...
```
