Before running populate.sh, please make sure that:

1. DC is up and running on a new DB instance;  default URL is http://localhost:9060 (if you ran the full ODM stack with docker-compose.)

2. The 'jq' utility is also required.  (On macOS you can install it with 'brew install jq';  on Linux it is provided as a standard package.)

After running the populate script, you should be able to stop all services but the database server (run this command in the same directory as the docker-compose.yml file you used):

    docker-compose rm -f -s odm-decisioncenter odm-decisionrunner odm-decisionserverconsole odm-decisionserverruntime

and to export the DB contents;  for instance, when running PostgreSQL:

    PGPASSWORD=<odmdbpassword> pg_dump -C -Fc -h localhost -U odmusr odmdb > odmdb.dump
