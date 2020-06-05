copy sunbird.usr_external_identity(provider,
idtype,
externalid,
createdby,
createdon,
lastupdatedby,
lastupdatedon,
originalexternalid,
originalidtype,
originalprovider,
userid) to 'usr_external_identity.csv' with header=true and numprocesses=8 and maxattempts=10;

DROP TABLE IF EXISTS sunbird.usr_external_identity;

CREATE TABLE sunbird.usr_external_identity(
externalId text,
provider text,
idType text,
userId text,
createdOn timestamp,
lastUpdatedOn timestamp,
createdBy text,
lastUpdatedBy text,
originalExternalId text,
originalIdType text,
originalProvider text,
PRIMARY KEY(userId, idType, provider));


copy sunbird.usr_external_identity(provider,
idtype,
externalid,
createdby,
createdon,
lastupdatedby,
lastupdatedon,
originalexternalid,
originalidtype,
originalprovider,
userid) from 'usr_external_identity.csv' with header=true and chunksize=2000 and numprocesses=8;
