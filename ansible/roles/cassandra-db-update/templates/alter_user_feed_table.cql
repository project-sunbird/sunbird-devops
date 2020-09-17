copy sunbird.user_feed(
id,
category,
createdby,
createdon,
data,
expireon,
priority,
status,
updatedby,
updatedon,
userid) to 'user_feed.csv' with header=true and numprocesses=8 and maxattempts=10;

DROP TABLE IF EXISTS sunbird.user_feed;

CREATE TABLE sunbird.user_feed(
id text,
category text,
createdby text,
createdon timestamp,
data text,
expireon timestamp,
priority int,
status int,
updatedby text,
updatedon timestamp,
userid text,
PRIMARY KEY(userId, category, id));

copy sunbird.user_feed(id,
category,
createdby,
createdon,
data,
expireon,
priority,
status,
updatedby,
updatedon,
userid) from 'user_feed.csv' with header=true and chunksize=2000 and numprocesses=8 and maxattempts=10;
