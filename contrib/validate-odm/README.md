The script [validate-odm.sh](./validate-odm.sh) can be used to validate the installation of ODM.

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
- Set the required environment variables manually or use a `.env` file.
  Refer to [Environment Variables](#Environment-Variables) for more information.

## Usage

```
./validate-odm.sh [-c] [-h]
```

Optional script parameters:
- `-c` :  Cleans the created ruleApps at the end of the test.
- `-h` :  Displays the help page.

### Environment Variables

The script configuration file requires the following environment variables to be defined manually or in a `.env` file:

* **ODM endpoints configuration**
  - `DC_URL`  : URL of the Decision Center instance to test.
  - `RES_URL` : URL of the Decision Server Console (RES) instance to test.
  - `DSR_URL` : URL of the Decision Server Runtime instance to test.

* **Authentication configuration**
  - To use *basic* authentication mode, define:
    - `ODM_CREDS` : Credentials to connect to ODM using the format `<user>:<password>`
  - To use *openID* authentication mode, define:
    - `ODM_CREDS` : Credentials to get the token using the format `<clientId>:<clientSecret>`
    - `OPENID_URL` : URL of the OpenId Server

You can fill the [.env.template](./.env.template) file with your configuration.

### Examples

* To validate an ODM instance described in the `.env` file and clean at the end of the test:
  ```
  ./validate-odm.sh -c
  ```

* To validate an ODM instance setting environment variables manually:
  ```
  export DC_URL=https://<clusterip>:<dc-port>
  export RES_URL=https://<clusterip>:<res-port>
  export DSR_URL=https://<clusterip>:<dsr-port>
  export ODM_CREDS=odmAdmin:odmAdmin

  ./validate-odm.sh
  ```
