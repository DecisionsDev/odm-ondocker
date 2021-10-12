# Add IBM License Metering annotations

License annotations let you track usage based on the limits defined on the container, rather than on the underlying machine. You configure your clients to deploy the container with specific annotations that the IBM® License Service then uses to track usage.

The IBM License Service needs to be installed on the Kubernetes cluster where the IBM ODM container is deployed to track usage. Further information regarding the supported environments and installation instructions can be found on the [ibm-licensing-operator](https://www.ibm.com/links?url=https%3A%2F%2Fgithub.com%2FIBM%2Fibm-licensing-operator) page on GitHub.

The IBM License Service processes pod annotations to track licenses. Therefore product teams should use specific metering annotations in the `spec.template.metadata.annotations` section of their Kubernetes pod template.

Based on your deployment type, use the following annotations:
- [IBM ODM on K8S (Production)](#ibm-odm-on-k8s-production)
- [IBM ODM on K8S (Non-Production)](#ibm-odm-on-k8s-non-production)


## Guidance

**containername** should be set to the name of the container as set in `spec.template.spec.containers.name` parameter of your [pod template](https://kubernetes.io/docs/concepts/workloads/pods/#pod-templates) except for *decisionServerConsole* container where it should be set to **""**, since *decisionServerConsole* container is not charged.


## IBM ODM on K8S (Production)

- For all containers except decision-runner:

  ```yaml
  spec:
    template:
      metadata:
        annotations:
          productName: "IBM Operational Decision Manager"
          productID: "b1a07d4dc0364452aa6206bb6584061d"
          productVersion: "8.11.0"
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
          productVersion: "8.110"
          productMetric: "PROCESSOR_VALUE_UNIT"
          productChargedContainers: <containername>
  ```

  > **Note:** *Decision Runner* container is always charged in non-production mode

## IBM ODM on K8S (Non-Production)

```yaml
spec:
  template:
    metadata:
      annotations:
        productName: "IBM Operational Decision Manager - Non Prod"
        productID: "e32af5770e06427faae142993c691048"
        productVersion: "8.11.0"
        productMetric: "PROCESSOR_VALUE_UNIT"
        productChargedContainers: <containername>
```

## Example

Decision Center Production example:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-odm-decisioncenter
  ...
spec:
  ...
  template:
    metadata:
      ...
      annotations:
        productName: "IBM Operational Decision Manager"
        productID: "b1a07d4dc0364452aa6206bb6584061d"
        productVersion: "8.11.0"
        productMetric: "PROCESSOR_VALUE_UNIT"
        productChargedContainers: my-odm-decisioncenter
    spec:
      ...

      containers:
      - name: my-odm-decisioncenter
        image: ibmcom/odm-decisioncenter:8.11.0-amd64
        ...
```
