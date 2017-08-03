##Deploying a sharded MongoDB(3.2+) cluster with Ansible(2.1+)
------------------------------------------------------------------------------

- Requires Ansible 2.1+ 
- Expects CentOS/RHEL 7 hosts

Rewrite from [ansible mongodb example](https://github.com/ansible/ansible-examples/tree/master/mongodb) with mongodb3.2, ansible2.1, CentOS 7.
 
![Alt text](images/site.png "Site")

The diagram above illustrates the deployment model for a MongoDB cluster deployed by Ansible. 
This deployment model focuses on deploying three shard servers, each having a replica set, 
with the backup replica servers serving as the other two shard primaries. The configuration 
servers are co-located with the shards. The mongos servers are best deployed on seperate servers.
This is the minimum recomended configuration for a production-grade MongoDB deployment.
Please note that the playbooks are capable of deploying N node clusters, not limited to three. 
Also, all the processes are secured using keyfiles.
 
### Deployment Example
------------------------------------------------------------------------------

The inventory file looks as follows:

		#The site wide list of mongodb servers
		[mongo_servers]
		mongo1 mongod_port=2700
		mongo2 mongod_port=2701
		mongo3 mongod_port=2702

		#The list of servers where replication should happen, including the master server.
		[replication_servers]
		mongo3
		mongo1
		mongo2

		#The list of mongodb configuration servers, make sure it is 1 or 3
		[mongoc_servers]
		mongo1
		mongo2
		mongo3

		#The list of servers where mongos servers would run. 
		[mongos_servers]
		mongos1
		mongos2

Build the site by mongodb playbook using the following command:

		ansible-playbook -i hosts site.yml
		
Build the site by **vagrant ansible provision** using the following command:

		vagrant up		


### Verifying the Deployment  
------------------------------------------------------------------------------


Once configuration and deployment has completed we can check replication set availability by connecting to individual primary replication set nodes.
Run `vagrant ssh mongo1 ` to login then exec `mongo locahost/admin -u admin -p 123456` 
and issue the command to query the status of replication set, we should get a similar output.
 
    mongos> sh.status()
    --- Sharding Status --- 
      sharding version: {
        "_id" : 1,
        "minCompatibleVersion" : 5,
        "currentVersion" : 6,
        "clusterId" : ObjectId("586e54fa29837f51186882a2")
    }
      shards:
        {  "_id" : "mongo1",  "host" : "mongo1/mongo1:2700,mongo2:2700,mongo3:2700" }
        {  "_id" : "mongo2",  "host" : "mongo2/mongo1:2701,mongo2:2701,mongo3:2701" }
        {  "_id" : "mongo3",  "host" : "mongo3/mongo1:2702,mongo2:2702,mongo3:2702" }
      active mongoses:
        "3.2.11" : 2
      balancer:
        Currently enabled:  yes
        Currently running:  no
        Failed balancer rounds in last 5 attempts:  0
        Migration Results for the last 24 hours: 
            4 : Success
      databases:
        {  "_id" : "test",  "primary" : "mongo2",  "partitioned" : true }
            test.messages
                shard key: { "createTime" : 1 }
                unique: false
                balancing: true
                chunks:
                    mongo1	1
                    mongo2	1
                    mongo3	1
                { "createTime" : { "$minKey" : 1 } } -->> { "createTime" : ISODate("0381-01-05T14:15:47.299Z") } on : mongo1 Timestamp(2, 0) 
                { "createTime" : ISODate("0381-01-05T14:15:47.299Z") } -->> { "createTime" : ISODate("2584-01-05T14:15:47.299Z") } on : mongo3 Timestamp(3, 0) 
                { "createTime" : ISODate("2584-01-05T14:15:47.299Z") } -->> { "createTime" : { "$maxKey" : 1 } } on : mongo2 Timestamp(3, 1) 
            test.user
                shard key: { "_id" : "hashed" }
                unique: false
                balancing: true
                chunks:
                    mongo1	2
                    mongo2	2
                    mongo3	2
                { "_id" : { "$minKey" : 1 } } -->> { "_id" : NumberLong("-6148914691236517204") } on : mongo1 Timestamp(3, 2) 
                { "_id" : NumberLong("-6148914691236517204") } -->> { "_id" : NumberLong("-3074457345618258602") } on : mongo1 Timestamp(3, 3) 
                { "_id" : NumberLong("-3074457345618258602") } -->> { "_id" : NumberLong(0) } on : mongo2 Timestamp(3, 4) 
                { "_id" : NumberLong(0) } -->> { "_id" : NumberLong("3074457345618258602") } on : mongo2 Timestamp(3, 5) 
                { "_id" : NumberLong("3074457345618258602") } -->> { "_id" : NumberLong("6148914691236517204") } on : mongo3 Timestamp(3, 6) 
                { "_id" : NumberLong("6148914691236517204") } -->> { "_id" : { "$maxKey" : 1 } } on : mongo3 Timestamp(3, 7) 


We can check the status of the shards as follows: connect to the mongos service `mongo localhost/test -u admin -p 123456` 
and issue the following command to get the status of the Shards:

    mongos> db.user.find({_id: 1 }).explain()
    {
        "queryPlanner" : {
            "mongosPlannerVersion" : 1,
            "winningPlan" : {
                "stage" : "SINGLE_SHARD",
                "shards" : [
                    {
                        "shardName" : "mongo3",
                        "connectionString" : "mongo3/mongo1:2702,mongo2:2702,mongo3:2702",
                        "serverInfo" : {
                            "host" : "mongo3",
                            "port" : 2702,
                            "version" : "3.2.11",
                            "gitVersion" : "009580ad490190ba33d1c6253ebd8d91808923e4"
                        },
                        "plannerVersion" : 1,
                        "namespace" : "test.user",
                        "indexFilterSet" : false,
                        "parsedQuery" : {
                            "_id" : {
                                "$eq" : 1
                            }
                        },
                        "winningPlan" : {
                            "stage" : "SHARDING_FILTER",
                            "inputStage" : {
                                "stage" : "IDHACK"
                            }
                        },
                        "rejectedPlans" : [ ]
                    }
                ]
            }
        },
        "ok" : 1
    }
