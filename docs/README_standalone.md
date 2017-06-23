

This demo shows how to start in Docker an ODM topology using Docker Compose.

First, you need to install [Docker and Docker Compose](https://docs.docker.com/compose/#installation-and-set-up).

## Run the standalone dev topology.
To run the demo, you just need to start Docker Compose:
```
docker-compose up
```

This command creates tree docker containers:

* 1 for the DB Derby base
* 1 for the Decision Server runtime.
* 1 for the Decision Server console.

You can access the application with the URL:
[RES Console (resAdmin/resAdmin)](http://localhost:9080/res) and
[Decision Server runtime](http://localhost:9090/DecisionService)
	
You can check the containers status using the command:
```
docker-compose ps
```

You can check the RES console and DecisionService runtime link in the res console serverinfo tab. You should perform at 
one execution to activate the DecisionSer


## Run the cluster topology.

To run the demo, you just need to start Docker Compose:
```
docker-compose -f docker-compose-cluster.yml up
```

This command creates 4 docker containers:

* 1 for the DB Derby base
* 1 for the load balancer
* 1 for the Decision Server runtime.
* 1 for the Decision Server console.

You can access the application with the URL: 
[RES Console (resAdmin/resAdmin)](http://localhost:9080/res) / 
[Decision Server runtime](http://localhost/DecisionService) / [The load balancer stats](http://localhost:1936/#stats)

To add a node to the cluster:
```
docker-compose -f docker-compose-cluster.yml scale decisionserverruntimer=2
```


You should see 2 runtime attach to the RES console. The load balancer is configured with the round robin algorithm.



### Global and default settings of the Operational Decision Manager docker images ###

Settings in this part is immutable, you have to redeploy Operation Decision service to make the changes take effects


|Image Name|Environment Variable|Default|Description|
|:-----:|:-----:|:-----:|:----------|
| DecisionServerConsole | DECISION_SERVICE_URL | http://localhost:9090/DecisionService | |  



