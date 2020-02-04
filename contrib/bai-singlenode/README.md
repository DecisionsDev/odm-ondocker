# Integration of BAI Single node with ODM Evaluation

The goal of this integration is to easily run ODM with BAI Single Node with a minimum effort.

TODO: Verify the naming of BAI Single node.

# How to use it
  - 1. Install BAI Single node TODO: Put a link to the download page or information in a KC). Installation directory is called BAI_DIR.
  - 2. Git clone this repository or download a odm-ondocker Release. Git clone directory is called ODM_DIR.
  - 3. Create a directory <BAI_DIR>/odm
  - 4. Copy the directory <ODM_DIR>/contrib/bai-singlenode/* to <BAI_DIR>/odm
    - You should see this layout
    [TODO] Put a screenshot of the finder of BAI_DIR
  - 5. Run BAI Single node.
      - cd <BAI_DIR>/bin
      - ./bai-start --acceptLicense --init
  - 6. Run ODM
      - cd <BAI_DIR>/odm
      - ./runODMToBAI.sh
      -> Wait a couple of minutes .....
      [TODO] Modify the runODMTOBAI.sh to perfom change in the ruleset property.

  - 7. Play with the Integration
      - Open a web browser
      - Open the kibana dashboard. http://localhost:8105/ [TODO] Verify the url
        - Go to dashboard and select the Decision Dashboard
        - The dashboard should be empty
      - Open http://localhost:9060/sample-web [TODO] Verify the cpe_url
        - Click "Validate Loan" button multiple times
      - Go back to the dashboard. The loan events should be displayed in the dashboard.
