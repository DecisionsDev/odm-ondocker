# Integration of BAI single node deployment with ODM Evaluation

The goal of this integration is to easily run ODM and emit events to BAI single node deployment with a minimum effort.


# How to use it

  1. Install and deploy BAI on a single node. To do this you need to download the .tgz archive from PPA. For full details of installation process see https://www.ibm.com/support/knowledgecenter/en/SSYHZ8_19.0.x/com.ibm.dba.install/bai_sn_topics/tsk_bai_single_node_deploy.html. The BAI installation directory is referred to as BAI_DIR.
  2. Git clone this repository, or download an odm-ondocker release. The git clone directory is referred to as ODM_DIR.
  3. Create a directory <BAI_DIR>/odm
  4. Copy the directory <ODM_DIR>/contrib/bai-singlenode/* to <BAI_DIR>/odm
    - You should see this layout
    [TODO] Put a screenshot of the finder of BAI_DIR
  5. Run BAI
      - cd <BAI_DIR>/bin
      - ./bai-start --acceptLicense --init
     <b>Note:</b> The first time you run BAI single node deployment you need to provide the hostname of your machine. This hostname is used for certificate generation. The hostname can change depending on your network. A good workaround is to add an entry in the /etc/hosts file of your machine to map a symbolic hostname, eg MyMachine, to the IP address; you then simply update the IP address in the file when you move networks. 
  6. Run ODM
    - cd <BAI_DIR>/odm
    - ./runODMToBAI.sh
    -> Wait a couple of minutes .....
  7. Configure the ruleset property of the sample to emit events
    - cd <BAI_DIR>/odm
    - ./setEmitterProps
    If the script fails you can set the properties manually in the RES console, see https://www.ibm.com/support/knowledgecenter/en/SSQP76_8.10.x/com.ibm.odm.dserver.rules.res.console/topics/con_rescons_rs_prop_bai.html.
  8. Play with the integration
      - Open a web browser
      - Open the BAI kibana dashboard. http://localhost:8105/ [TODO] Verify the url
        - Login with your credential
        - Go to Dashboards and select the Decision Dashboard
        - The dashboard should be empty
      - Open http://localhost:9060/sample-web [TODO] Verify the cpe_url
        - Click "Validate Loan" button multiple times
      - Go back to the dashboard. The loan events should be displayed in the dashboard
