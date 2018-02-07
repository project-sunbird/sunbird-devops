CREATE KEYSPACE portal 
WITH replication = {'class':'SimpleStrategy', 'replication_factor' : 1};
USE portal;
CREATE TABLE IF NOT EXISTS sessions (
   sid text,
   session text,
   expires timestamp,
   PRIMARY KEY(sid)
);