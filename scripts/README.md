The script [script-getting-started.sh](./script-getting-started.sh) can be used to validate the installation of ODM.

The script performs the following scenario:
1. Import the decision service
2. Run Main Scoring test suite
3. Generate and deploy the RuleApps
4. Verify the RuleApps are present in RES
5. Execute a RuleApp in DSR
6. [Optional] Delete the RuleApps

## Prerequisites

- Start ODM components.
  You can use ODM docker images, ODM on K8S chart or and ODM instance deployed with the CP4BA operator.
- Take a note of the endpoints of your components:
  - Decision Center (DC)
  - Decision Server Console (RES)
  - Decision Server Runtime (DSR) components
- Update the configuration file with the ODM endpoints and authentication parameters.
  Refer to [Parameters](#Parameters) for more information.

## Usage

```
./script-getting-started.sh [-f <config_files>] [-c] [-h]
```

Optional script parameters:
- `-f` :  The path of the properties files containing the configuration of the ODM instance to validate. Default value is `./config.properties`
- `-c` :  Automatically cleans the created ruleApps at the end of the test.
- `-h` :  Displays the help page.

### Configuration file

The script configuration file requires the following parameters to be defined:

* **ODM components endpoints**
  - `DC_URL`  : URL of the Decision Center instance to test.
  - `RES_URL` : URL of the Decision Server Console (RES) instance to test.
  - `DSR_URL` : URL of the Decision Server Runtime instance to test.

* **Authentication configuration**
  - To use *basic* authentication mode, define:
    - `ODM_CREDS` : Credentials to connect to ODM using the format `<user>:<password>`
  - To use *openID* authentication mode, define:
    - `ODM_CREDS` : Credentials to get the token using the format `<clientId>:<clientSecret>`
    - `openIdUrl` : URL of the OpenId Server

You can fill the [config.properties.template](./config.properties.template) file with your configuration.

### Examples

* To validate an ODM instance described in the default `config.properties` file and clean at the end of the test:
  ```
  ./script-getting-started.sh -c
  ```

* To validate an ODM instance described in a custom `path/config-test.properties` file
  ```
  ./script-getting-started.sh -f path/config-test.properties
  ```
