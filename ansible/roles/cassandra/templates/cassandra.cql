CREATE KEYSPACE IF NOT EXISTS sunbird WITH replication = {'class':'SimpleStrategy','replication_factor':1};

//to change cluster name
//UPDATE system.local SET cluster_name = 'sunbird' where key='local';
//ALTER USER cassandra WITH PASSWORD 'password';
USE sunbird;

/*
creation of id= one way hash of (userId##courseId) here courseId is identifier of course mgmt table
toc url we have to generate through json of content id from ekStep 
here status is (default(0),inProgress(1),completed(2))
progress is no of content completed
*/
CREATE TABLE IF NOT EXISTS sunbird.course_enrollment(id text, courseId text, courseName text,userId text,enrolledDate text,
description text,tocUrl text,status int,active boolean,delta text,grade text,progress int,lastReadContentId text,
lastReadContentStatus int,addedBy text,courseLogoUrl text,dateTime timestamp,contentId text,PRIMARY KEY (id));

CREATE INDEX inx_ce_userId ON sunbird.course_enrollment (userId);
CREATE INDEX inx_ce_courseId ON sunbird.course_enrollment (courseId);
CREATE INDEX inx_ce_course_name ON sunbird.course_enrollment (courseName);
CREATE INDEX inx_ce_status ON sunbird.course_enrollment (status);

/*
creation of id = one way hash of (userId##contentId##courseId) 
status is (default(0),inProgress(1),completed(2))
*/
CREATE TABLE IF NOT EXISTS sunbird.content_consumption(id text, contentId text, courseId text, userId text,viewPosition text,viewCount int,lastAccessTime text,
contentVersion text,completedCount int,status int,result text,score text,grade text,lastUpdatedTime text,lastCompletedTime text,dateTime timestamp,PRIMARY KEY (id));

CREATE INDEX inx_cc_userId ON sunbird.content_consumption (userId);
CREATE INDEX inx_cc_contentId ON sunbird.content_consumption (contentId);
CREATE INDEX inx_cc_status ON sunbird.content_consumption (status);
CREATE INDEX inx_cc_courseId ON sunbird.content_consumption (courseId);

/*
creation of id = using timestamp and env 
 id and courseId both are same
content id is from ekstep 
status DRAFT("draft"), LIVE("live"), RETIRED("retired")
contentType (pdf,video,word doc etc)
tutor   map<id,name>
*/      
CREATE TABLE IF NOT EXISTS sunbird.course_management(id text, courseId text, contentId text, courseName text,courseType text,
facultyId text,facultyName text,organisationId text,organisationName text,enrollementStartDate text,enrollementEndDate text,
courseDuration text,description text,status text,addedBy text,addedByName text,publishedBy text,publishedByName text,createdDate text,
publishedDate text,updatedDate text,updatedBy text,updatedByName text,contentType text,createdfor list<text>,noOfLectures int,tocUrl text,
tutor map<text,text>,courseLogoUrl text,courseRating text,userCount int,PRIMARY KEY (id));

CREATE INDEX inx_cm_facultyId ON sunbird.course_management (facultyId);
CREATE INDEX inx_cm_organisationId ON sunbird.course_management (organisationId);
CREATE INDEX inx_cm_courseId ON sunbird.course_management (courseId);
CREATE INDEX inx_cm_course_name ON sunbird.course_management (courseName);
CREATE INDEX inx_cm_status ON sunbird.course_management (status);
CREATE INDEX inx_cm_contentId ON sunbird.course_management (contentId);

/*
creation of id = one way hash of userName
here id and userId both are same
 currently username and email is same
email and username is unique
*/
CREATE TABLE IF NOT EXISTS  sunbird.user(id text,userId text,userName text, email text,phone text,aadhaarNo text,createdDate text,updatedDate text,updatedBy text,
lastLoginTime text,status int,firstName text,lastName text,password text,avatar text,gender text,language text,state text,city text,zipcode text,PRIMARY KEY (id));

CREATE INDEX inx_u_email ON sunbird.user (email);
CREATE INDEX inx_u_phone ON sunbird.user (phone);
CREATE INDEX inx_u_status ON sunbird.user (status);
CREATE INDEX inx_u_userId ON sunbird.user (userId);
CREATE INDEX inx_u_userName ON sunbird.user (userName);

//user_auth
//id is auth token
CREATE TABLE IF NOT EXISTS sunbird.user_auth(id text, userId text,createdDate text,updatedDate text,source text,PRIMARY KEY (id));
CREATE INDEX inx_ua_userId ON sunbird.user_auth (userId);
CREATE INDEX inx_ua_source ON sunbird.user_auth (source);

//organisation
CREATE TABLE IF NOT EXISTS sunbird.organisation(id text, orgName text, description text,communityId text,createdBy text,createdByName text,createdDate text,
updatedDate text,updatedBy text,status int,relation text,parentOrgId text,orgType text,state text,city text,zipcode text,orgCode text,dateTime timestamp,PRIMARY KEY (id));

CREATE INDEX inx_org_orgName ON sunbird.organisation (orgName);
CREATE INDEX inx_org_status ON sunbird.organisation (status);
//page_management
//id=  using timestamp and env 
CREATE TABLE sunbird.page_management(id text, name text, appMap text,portalMap text,createdDate text,createdBy text,
updatedDate text,updatedBy text,organisationId text,PRIMARY KEY (id));

CREATE INDEX inx_pm_pageName ON sunbird.page_management (name);
CREATE INDEX inx_vm_organisationId ON sunbird.page_management (organisationId);

//page_section
//id=  using timestamp and env 
CREATE TABLE IF NOT EXISTS sunbird.page_section(id text, name text, sectionDataType text,description text,display text,
searchQuery text,createdDate text,createdBy text,updatedDate text,updatedBy text,imgUrl text,alt text,status int,PRIMARY KEY (id));
CREATE INDEX inx_ps_sectionDataType ON sunbird.page_section (sectionDataType);
CREATE INDEX inx_ps_sectionName ON sunbird.page_section (name);

//Assessment Eval
//id=  using timestamp and env 
CREATE TABLE IF NOT EXISTS sunbird.assessment_eval(id text, contentId text, courseId text, userId text,assessmentItemId text,
createdDate text,result text,score text,attemptId text,attemptedCount int,PRIMARY KEY (id));

CREATE INDEX inx_ae_userId ON sunbird.assessment_eval (userId);
CREATE INDEX inx_ae_contentId ON sunbird.assessment_eval (contentId);
CREATE INDEX inx_ae_assessmentItemId ON sunbird.assessment_eval (assessmentItemId);
CREATE INDEX inx_ae_courseId ON sunbird.assessment_eval (courseId);

//Assessment item 
//id= using timestamp and userId
CREATE TABLE IF NOT EXISTS sunbird.assessment_item(id text, contentId text, courseId text, userId text,assessmentItemId text,
assessmentType text,attemptedDate text,createdDate text,timeTaken int,result text,score text,maxScore text,answers text,
evaluationStatus boolean,processingStatus boolean,attemptId text,PRIMARY KEY (id));

CREATE INDEX inx_ai_userId ON sunbird.assessment_item (userId);
CREATE INDEX inx_ai_contentId ON sunbird.assessment_item (contentId);
CREATE INDEX inx_ai_assessmentItemId ON sunbird.assessment_item (assessmentItemId);
CREATE INDEX inx_ai_courseId ON sunbird.assessment_item (courseId);
CREATE INDEX inx_ai_processingStatus ON sunbird.assessment_item (processingStatus);

ALTER TABLE sunbird.course_management DROP noOfLectures;
ALTER TABLE sunbird.course_management ADD noOfLectures int;
ALTER TABLE sunbird.assessment_item DROP evaluationStatus;
ALTER TABLE sunbird.assessment_item DROP processingStatus;
ALTER TABLE sunbird.assessment_item ADD evaluationStatus boolean;
ALTER TABLE sunbird.assessment_item ADD processingStatus boolean;
ALTER TABLE sunbird.assessment_eval DROP assessmentItemId;
ALTER TABLE sunbird.assessment_eval DROP maxScore;
ALTER TABLE sunbird.page_management ADD organisationId text;
ALTER TABLE sunbird.page_management DROP appMap;
ALTER TABLE sunbird.page_management DROP portalMap;
ALTER TABLE sunbird.page_management ADD appMap text;
ALTER TABLE sunbird.page_management ADD portalMap text;
ALTER TABLE sunbird.organisation ADD orgCode text;

//2017-06-30 changes for user and organisation
ALTER TABLE sunbird.user DROP zipcode;
ALTER TABLE sunbird.user DROP city;
ALTER TABLE sunbird.user DROP state;
ALTER TABLE sunbird.user DROP language;
ALTER TABLE sunbird.user ADD thumbnail text;
 ALTER TABLE sunbird.user ADD dob text;
 ALTER TABLE sunbird.user ADD regOrgId text;
 ALTER TABLE sunbird.user ADD subject list<text>;
 ALTER TABLE sunbird.user ADD language list<text>;
 ALTER TABLE sunbird.user ADD grade list<text>;

 
 CREATE TABLE IF NOT EXISTS sunbird.user_external_identity(id text, userId text, externalId text,source text,isVerified boolean,PRIMARY KEY (id));
CREATE INDEX inx_uei_userid ON sunbird.user_external_identity (userId);
CREATE INDEX inx_uei_externalId ON sunbird.user_external_identity (externalId);
CREATE INDEX inx_uei_source ON sunbird.user_external_identity (source);

CREATE TABLE IF NOT EXISTS sunbird.address(id text, userId text, country text,state text,city text,zipCode text,addType text,createdDate text,createdBy text,updatedDate text,updatedBy text, PRIMARY KEY (id));
CREATE INDEX inx_add_userid ON sunbird.address (userId);
CREATE INDEX inx_add_addType ON sunbird.address (addType);

CREATE TABLE IF NOT EXISTS sunbird.user_education(id text, userId text, courseName text,duration int,yearOfPassing int,percentage double,grade text,name text,boardOrUniversity text,addressId text,createdDate text,createdBy text,updatedDate text,updatedBy text, PRIMARY KEY (id));
CREATE INDEX inx_ueu_userid ON sunbird.user_education (userId);

CREATE TABLE IF NOT EXISTS sunbird.user_job_profile(id text, userId text, jobName text,role text,joiningDate text,endDate text,orgName text,orgId text,subject list<text>,addressId text,boardName text,isVerified boolean,isRejected boolean,verifiedDate text,verifiedBy text,createdDate text,createdBy text,updatedDate text,updatedBy text, PRIMARY KEY (id));
CREATE INDEX inx_ujp_userid ON sunbird.user_job_profile (userId); 

CREATE TABLE IF NOT EXISTS sunbird.user_org(id text, userId text, role text,orgId text,orgJoinDate text,orgLeftDate text,isApproved boolean,
isRejected boolean,approvedBy text,approvalDate text,updatedDate text,updatedBy text, PRIMARY KEY (id));
CREATE INDEX inx_uorg_userid ON sunbird.user_org(userId); 
CREATE INDEX inx_uorg_orgId ON sunbird.user_org(orgId);
 
CREATE TABLE IF NOT EXISTS sunbird.subject(id text, name text, PRIMARY KEY (id));
CREATE INDEX inx_sb_name ON sunbird.subject(name); 

CREATE TABLE IF NOT EXISTS sunbird.role(id text, name text, PRIMARY KEY (id));
CREATE INDEX inx_role_name ON sunbird.role(name);

ALTER TABLE sunbird.organisation DROP city;
ALTER TABLE sunbird.organisation DROP state;
ALTER TABLE sunbird.organisation DROP zipcode;
ALTER TABLE sunbird.organisation DROP relation;
ALTER TABLE sunbird.organisation DROP createdbyname;

ALTER TABLE sunbird.organisation ADD imgUrl text;
ALTER TABLE sunbird.organisation ADD thumbnail text;
ALTER TABLE sunbird.organisation ADD channel text;
ALTER TABLE sunbird.organisation ADD preferredLanguage text;
ALTER TABLE sunbird.organisation ADD homeUrl text;
ALTER TABLE sunbird.organisation ADD isRootOrg boolean;
ALTER TABLE sunbird.organisation ADD addId text;
ALTER TABLE sunbird.organisation ADD noOfmembers int;
ALTER TABLE sunbird.organisation ADD orgCode text;
ALTER TABLE sunbird.organisation ADD isApproved boolean;
ALTER TABLE sunbird.organisation ADD approvedBy text;
ALTER TABLE sunbird.organisation ADD approvedDate text;
//ALTER TABLE sunbird.organisation ADD isRejected boolean;

CREATE INDEX inx_org_channel ON sunbird.organisation(channel);
CREATE INDEX inx_org_orgType ON sunbird.organisation(orgType);
CREATE INDEX inx_org_orgCode ON sunbird.organisation(orgCode); 

CREATE TABLE IF NOT EXISTS sunbird.org_type(id text, name text, PRIMARY KEY (id));
CREATE INDEX inx_ot_name ON sunbird.org_type(name);  

CREATE TABLE IF NOT EXISTS sunbird.org_mapping(id text, orgIdOne text,relation text,orgIdTwo text, PRIMARY KEY (id));
CREATE INDEX inx_om_orgIdOne ON sunbird.org_mapping(orgIdOne);  
CREATE INDEX inx_om_orgIdTwo ON sunbird.org_mapping(orgIdTwo);    

CREATE TABLE IF NOT EXISTS sunbird.role(id text, name text,status int, PRIMARY KEY (id));
CREATE INDEX inx_ro_master_name ON sunbird.role(name);  

insert into role (id,name,status) values ('r_101','ADMIN',1);
insert into role (id,name,status) values ('r_102','ORG_ADMIN',1);
insert into role (id,name,status) values ('r_103','ORG_MODERATOR',1);
insert into role (id,name,status) values ('r_104','CONTENT_CREATOR',1);
insert into role (id,name,status) values ('r_105','CONTENT_REVIEWER',1);
insert into role (id,name,status) values ('r_106','ORG_MEMBER',1);


ALTER TABLE sunbird.user ADD rootOrgId text;
ALTER TABLE sunbird.address ADD addressLine1 text;
ALTER TABLE sunbird.address ADD addressLine2 text;
ALTER TABLE sunbird.user_education ADD degree text;

insert into sunbird.role (id,name,status) values ('r_101','SYSTEM_ADMINISTRATION',1);
insert into sunbird.role (id,name,status) values ('r_102','ORG_MANAGEMENT',1);
insert into sunbird.role (id,name,status) values ('r_103','MEMBERSHIP_MANAGEMENT',1);
insert into sunbird.role (id,name,status) values ('r_104','CONTENT_CREATION',1);
insert into sunbird.role (id,name,status) values ('r_105','CONTENT_REVIEW',1);
insert into sunbird.role (id,name,status) values ('r_106','CONTENT_CURATION',1);
insert into sunbird.role (id,name,status) values ('r_107','PUBLIC',1);


CREATE TABLE IF NOT EXISTS sunbird.master_action(id text, name text, PRIMARY KEY (id));
CREATE INDEX inx_ma_name ON sunbird.master_action(name); 

CREATE TABLE IF NOT EXISTS sunbird.url_action(id text, url text,name text, PRIMARY KEY (id));
CREATE INDEX inx_ua_name ON sunbird.url_action(name);
CREATE INDEX inx_ua_url ON sunbird.url_action(url);

CREATE TABLE IF NOT EXISTS sunbird.action_group(id text, actionId list<text>,groupName text, PRIMARY KEY (id));
CREATE INDEX inx_uacg_groupName ON sunbird.action_group(groupName);

CREATE TABLE IF NOT EXISTS sunbird.user_action_role(id text, actionGroupId list<text>,roleId text, PRIMARY KEY (id));
CREATE INDEX inx_uactr_roleId ON sunbird.user_action_role(roleId);

insert into sunbird.url_action(id,url,name) values ('1','','suspendOrg');
insert into sunbird.url_action(id,url,name) values ('2','','suspendUser');
insert into sunbird.url_action(id,url,name) values ('3','','createOrg');
insert into sunbird.url_action(id,url,name) values ('4','','updateOrg');
insert into sunbird.url_action(id,url,name) values ('5','','updateUser');
insert into sunbird.url_action(id,url,name) values ('6','','addMember');
insert into sunbird.url_action(id,url,name) values ('7','','removeOrg');
insert into sunbird.url_action(id,url,name) values ('8','','createUser');

insert into sunbird.url_action(id,url,name) values ('9','','removeMember');
insert into sunbird.url_action(id,url,name) values ('10','','suspendMember');
insert into sunbird.url_action(id,url,name) values ('11','','createCourse');
insert into sunbird.url_action(id,url,name) values ('12','','updateCourse');
insert into sunbird.url_action(id,url,name) values ('13','','createContent');
insert into sunbird.url_action(id,url,name) values ('14','','updateContent');
insert into sunbird.url_action(id,url,name) values ('15','','publishCourse');
insert into sunbird.url_action(id,url,name) values ('16','','publishContent');

insert into sunbird.url_action(id,url,name) values ('17','','flagCourse');
insert into sunbird.url_action(id,url,name) values ('18','','flagContent');
insert into sunbird.url_action(id,url,name) values ('19','','getProfile');
insert into sunbird.url_action(id,url,name) values ('20','','updateProfile');
insert into sunbird.url_action(id,url,name) values ('21','','readCourse');
insert into sunbird.url_action(id,url,name) values ('22','','readContent');
insert into sunbird.url_action(id,url,name) values ('23','','rateCourse');
insert into sunbird.url_action(id,url,name) values ('24','','rateContent');
insert into sunbird.url_action(id,url,name) values ('25','','searchCourse');
insert into sunbird.url_action(id,url,name) values ('26','','searchContent');

insert into sunbird.action_group(id,actionId,groupName) values ('ag_12',['1','2'],'SYSTEM_ADMINISTRATION');
insert into sunbird.action_group(id,actionId,groupName) values ('ag_13',['3','4','7','8','5'],'ORG_MANAGEMENT');	
insert into sunbird.action_group(id,actionId,groupName) values ('ag_14',['6','9','10'],'MEMBERSHIP_MANAGEMENT');	

insert into sunbird.action_group(id,actionId,groupName) values ('ag_15',['11','12','13','14'],'CONTENT_CREATION');
insert into sunbird.action_group(id,actionId,groupName) values ('ag_16',['15','16'],'CONTENT_REVIEW');	
insert into sunbird.action_group(id,actionId,groupName) values ('ag_17',['17','18','10'],'CONTENT_CURATION');		
insert into sunbird.action_group(id,actionId,groupName) values ('ag_17',['19','20','21','22','23','24','25','26'],'PUBLIC');

ALTER TABLE sunbird.user ADD loginId text;
ALTER TABLE sunbird.user ADD provider text;
ALTER TABLE sunbird.user_external_identity ADD idType text;

insert into sunbird.user_action_role(id,actiongroupid,roleid) values ('uar_1',['ag_17'],'r_107');
insert into  sunbird.user_action_role(id,actiongroupid,roleid) values ('uar_2',['ag_13'],'r_102');
insert into  sunbird.user_action_role(id,actiongroupid,roleid) values ('uar_3',['ag_14'],'r_103');
 insert into sunbird.user_action_role(id,actiongroupid,roleid) values ('uar_3',['ag_15'],'r_104');
 insert into sunbird.user_action_role(id,actiongroupid,roleid) values ('uar_3',['ag_16'],'r_105');
 insert into sunbird.user_action_role(id,actiongroupid,roleid) values ('uar_3',['ag_12'],'r_101');
 
ALTER TABLE sunbird.organisation DROP addId;
ALTER TABLE sunbird.organisation ADD addressId text;
ALTER TABLE sunbird.user ADD roles List<text>;
 
 
 CREATE TABLE IF NOT EXISTS sunbird.role_group(id text, name text, PRIMARY KEY (id));
 insert into sunbird.role_group (id,name) values ('SYSTEM_ADMINISTRATION','SYSTEM_ADMINISTRATION');
 insert into sunbird.role_group (id,name) values ('ORG_MANAGEMENT','ORG_MANAGEMENT');
 insert into sunbird.role_group (id,name) values ('MEMBERSHIP_MANAGEMENT','MEMBERSHIP_MANAGEMENT');
 insert into sunbird.role_group (id,name) values ('CONTENT_CREATION','CONTENT_CREATION');
 insert into sunbird.role_group (id,name) values ('CONTENT_CURATION','CONTENT_CURATION');
 insert into sunbird.role_group (id,name) values ('CONTENT_REVIEW','CONTENT_REVIEW');
 drop table sunbird.role;
CREATE TABLE IF NOT EXISTS sunbird.role(id text, name text,roleGroupId List<text>,status int, PRIMARY KEY (id));
CREATE INDEX inx_ro_master_name ON sunbird.role(name);
 insert into sunbird.role (id,name,rolegroupid,status) values ('ADMIN','ADMIN',['SYSTEM_ADMINISTRATION','ORG_MANAGEMENT'],1);
 insert into sunbird.role (id,name,rolegroupid,status) values ('ORG_ADMIN','ORG_ADMIN',['ORG_MANAGEMENT','MEMBERSHIP_MANAGEMENT'],1);
 insert into sunbird.role (id,name,rolegroupid,status) values ('ORG_MODERATOR','ORG_MODERATOR',['MEMBERSHIP_MANAGEMENT'],1);
 insert into sunbird.role (id,name,rolegroupid,status) values ('CONTENT_CREATOR','CONTENT_CREATOR',['CONTENT_CREATION'],1);
 insert into sunbird.role (id,name,rolegroupid,status) values ('CONTENT_REVIEWER','CONTENT_REVIEWER',['CONTENT_CREATION','CONTENT_CURATION','CONTENT_REVIEW'],1);
 drop table sunbird.url_action;
 CREATE TABLE IF NOT EXISTS sunbird.url_action(id text, url list<text>,name text, PRIMARY KEY (id));
 CREATE INDEX inx_ua_name ON sunbird.url_action(name);
CREATE INDEX inx_ua_url ON sunbird.url_action(url);

insert into sunbird.url_action (id,name) values ('suspendOrg','suspendOrg');
 insert into sunbird.url_action (id,name) values ('suspendUser','suspendUser');
 insert into sunbird.url_action (id,name) values ('createOrg','createOrg');
 insert into sunbird.url_action (id,name) values ('updateOrg','updateOrg');
 insert into sunbird.url_action (id,name) values ('removeOrg','removeOrg');
 insert into sunbird.url_action (id,name) values ('createUser','createUser');
 insert into sunbird.url_action (id,name) values ('updateUser','updateUser');
 insert into sunbird.url_action (id,name) values ('ORG_MANAGEMENT','ORG_MANAGEMENT');
 insert into sunbird.url_action (id,name) values ('createOrg','createOrg');
 insert into sunbird.url_action (id,name) values ('addMember','addMember');
 insert into sunbird.url_action (id,name) values ('removeMember','removeMember');
 insert into sunbird.url_action (id,name) values ('suspendMember','suspendMember');
 insert into sunbird.url_action (id,name) values ('createCourse','createCourse');
 insert into sunbird.url_action (id,name) values ('updateCourse','updateCourse');
 insert into sunbird.url_action (id,name) values ('createContent','createContent');
 insert into sunbird.url_action (id,name) values ('updateContent','updateContent');
 insert into sunbird.url_action (id,name) values ('flagCourse','flagCourse');
 insert into sunbird.url_action (id,name) values ('flagContent','flagContent');
 insert into sunbird.url_action (id,name) values ('publishCourse','publishCourse');
 insert into sunbird.url_action (id,name) values ('publishContent','publishContent');
 ALTER table sunbird.role_group add url_action_ids list<text>;
 
 update sunbird.role_group set url_action_ids=['addMember','removeMember','suspendMember'] where id='MEMBERSHIP_MANAGEMENT';
 update sunbird.role_group set url_action_ids=['createCourse','updateCourse','createContent','updateContent'] where id='CONTENT_CREATION';
 update sunbird.role_group set url_action_ids=['suspendOrg','suspendUser'] where id='SYSTEM_ADMINISTRATION';
 update sunbird.role_group set url_action_ids=['publishCourse','publishContent'] where id='CONTENT_REVIEW';
 update sunbird.role_group set url_action_ids=['createOrg','updateOrg','removeOrg','createUser','updateUser'] where id='ORG_MANAGEMENT';
 update sunbird.role_group set url_action_ids=['flagCourse','flagContent'] where id='CONTENT_CURATION';

 update sunbird.url_action set url=['/v1/course/publish'] where id='publishContent';
update sunbird.url_action set url=['/v1/user/create'] where id='addMember';
 update sunbird.url_action set url=['v1/course/create'] where id='createCourse';
update sunbird.url_action set url=['/v1/user/create'] where id='createUser';
 update sunbird.url_action set url=['/v1/course/publish'] where id='publishCourse';
update sunbird.url_action set url=['/v1/organisation/update'] where id='updateOrg';

drop index inx_uorg_orgid;
ALTER TABLE sunbird.user_org DROP orgid;
ALTER TABLE sunbird.user_org ADD organisationid text;
ALTER TABLE sunbird.user_org ADD addedby text;
ALTER TABLE sunbird.user_org ADD addedbyname text;
CREATE INDEX inx_uorg_orgid ON sunbird.user_org (organisationid);


/*
creation of id= one way hash of (userId##courseId) here courseId is identifier of EkStep course
toc url is generated from ekStep
here status is (default(0),inProgress(1),completed(2))
progress is no of content completed
*/
CREATE TABLE IF NOT EXISTS sunbird.user_courses(id text, courseId text, courseName text, userId text, batchId text, enrolledDate text,
description text,tocUrl text,status int,active boolean,delta text,grade text,progress int,lastReadContentId text,
lastReadContentStatus int,addedBy text,courseLogoUrl text, dateTime timestamp, contentId text, PRIMARY KEY (id));

CREATE INDEX inx_ucs_userId ON sunbird.user_courses (userId);
CREATE INDEX inx_ucs_courseId ON sunbird.user_courses (courseId);
CREATE INDEX inx_ucs_batchId ON sunbird.user_courses (batchId);
CREATE INDEX inx_ucs_course_name ON sunbird.user_courses (courseName);
CREATE INDEX inx_ucs_status ON sunbird.user_courses (status);

ALTER TABLE sunbird.user_external_identity DROP source;
ALTER TABLE sunbird.user_external_identity ADD provider text;
ALTER TABLE sunbird.user_external_identity ADD externalIdValue text;
DROP INDEX inx_uei_source;
CREATE INDEX inx_uei_provider ON sunbird.user_external_identity (provider);

//changes 7 July 2017 updated organization table
ALTER TABLE sunbird.organisation ADD rootOrgID text;
ALTER TABLE sunbird.org_mapping ADD rootOrgID text;
CREATE TABLE IF NOT EXISTS sunbird.org_type(id text, name text, PRIMARY KEY (id));
DROP INDEX sunbird.inx_org_status;
ALTER TABLE sunbird.organisation DROP status ;
ALTER TABLE sunbird.organisation ADD status text;

CREATE INDEX inx_org_status ON sunbird.organisation (status);

CREATE INDEX inx_u_loginId ON sunbird.user(loginId);

ALTER TABLE sunbird.user_job_profile ADD isCurrentJob boolean;
ALTER TABLE sunbird.content_consumption ADD progress int;
ALTER TABLE sunbird.content_consumption DROP viewPosition;

//changes on 12th july 2017
ALTER TABLE sunbird.user_job_profile ADD isDeleted boolean;
ALTER TABLE sunbird.user_education ADD isDeleted boolean;
ALTER TABLE sunbird.address ADD isDeleted boolean;
ALTER TABLE sunbird.user_org ADD isDeleted boolean;
ALTER TABLE sunbird.user ADD profileSummary text;

ALTER TABLE sunbird.organisation ADD source text;
ALTER TABLE sunbird.organisation ADD externalId text;

//to export data from csv to cassandra table run below command(for page_section and page_management table) 
// change the path of csv file
//COPY sunbird.page_management(id, appmap,createdby ,createddate ,name ,organisationid ,portalmap ,updatedby ,updateddate ) FROM '/tmp/cql/pageMgmt.csv';

//COPY sunbird.page_section(id, alt,createdby ,createddate ,description ,display ,imgurl ,name,searchquery , sectiondatatype ,status , updatedby ,updateddate) FROM '/tmp/cql/pageSection.csv';

