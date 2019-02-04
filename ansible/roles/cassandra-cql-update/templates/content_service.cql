{% if groups['cassandra-2'] is defined %}
CREATE KEYSPACE portal
WITH REPLICATION = { 'class' : 'NetworkTopologyStrategy', 'datacenter1' : 2 };
USE portal;
CREATE TABLE IF NOT EXISTS sessions (
   sid text,
   session text,
   expires timestamp,
   PRIMARY KEY(sid)
);
{% else %}
CREATE KEYSPACE portal
WITH replication = {'class':'SimpleStrategy', 'replication_factor' : 1};
USE portal;
CREATE TABLE IF NOT EXISTS sessions (
   sid text,
   session text,
   expires timestamp,
   PRIMARY KEY(sid)
);
{% endif %}
