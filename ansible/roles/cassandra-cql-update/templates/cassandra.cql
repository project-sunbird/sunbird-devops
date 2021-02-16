{% if (cassandra_cluster_size | int) > 1 %}
CREATE KEYSPACE IF NOT EXISTS sunbird WITH REPLICATION = { 'class' : 'NetworkTopologyStrategy', 'datacenter1' : 2 };
{% else %}
CREATE KEYSPACE IF NOT EXISTS sunbird WITH REPLICATION = {'class':'SimpleStrategy','replication_factor':1};
{% endif %}

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
creation of id = one way hash of (userId##contentId##courseId##batchId)
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
lastLoginTime text,status int,firstName text,lastName text,password text,avatar text,gender text,language list<text>,subject list<text>,grade list<text>,regOrgId text,
dob text,thumbnail text,PRIMARY KEY (id));

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
CREATE TABLE IF NOT EXISTS sunbird.organisation(id text, orgName text, description text,communityId text,createdBy text,createdDate text,
updatedDate text,updatedBy text,status int,parentOrgId text,orgType text,orgCode text,dateTime timestamp,PRIMARY KEY (id));

CREATE INDEX inx_org_orgName ON sunbird.organisation (orgName);
CREATE INDEX inx_org_status ON sunbird.organisation (status);
//page_management
//id=  using timestamp and env
CREATE TABLE IF NOT EXISTS sunbird.page_management(id text, name text, appMap text,portalMap text,createdDate text,createdBy text,
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
CREATE TABLE IF NOT EXISTS sunbird.assessment_eval(id text, contentId text, courseId text, userId text,
createdDate text,result text,score text,attemptId text,attemptedCount int,PRIMARY KEY (id));

CREATE INDEX inx_ae_userId ON sunbird.assessment_eval (userId);
CREATE INDEX inx_ae_contentId ON sunbird.assessment_eval (contentId);
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

DROP INDEX IF EXISTS sunbird.inx_ai_processingStatus;
DROP INDEX IF EXISTS sunbird.inx_ae_assessmentitemid;


CREATE TABLE IF NOT EXISTS sunbird.user_external_identity(id text, userId text, externalId text,source text,isVerified boolean,PRIMARY KEY (id));
CREATE INDEX inx_uei_userid ON sunbird.user_external_identity (userId);
CREATE INDEX inx_uei_externalId ON sunbird.user_external_identity (externalId);
CREATE INDEX inx_uei_source ON sunbird.user_external_identity (source);

//Address Type values(permanent, current, office, home)
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


ALTER TABLE sunbird.organisation ADD imgUrl text;
ALTER TABLE sunbird.organisation ADD thumbnail text;
ALTER TABLE sunbird.organisation ADD channel text;
ALTER TABLE sunbird.organisation ADD preferredLanguage text;
ALTER TABLE sunbird.organisation ADD homeUrl text;
ALTER TABLE sunbird.organisation ADD isRootOrg boolean;
ALTER TABLE sunbird.organisation ADD addId text;
ALTER TABLE sunbird.organisation ADD noOfmembers int;
ALTER TABLE sunbird.organisation ADD isApproved boolean;
ALTER TABLE sunbird.organisation ADD approvedBy text;
ALTER TABLE sunbird.organisation ADD approvedDate text;


CREATE INDEX inx_org_channel ON sunbird.organisation(channel);
CREATE INDEX inx_org_orgType ON sunbird.organisation(orgType);
CREATE INDEX inx_org_orgCode ON sunbird.organisation(orgCode);

CREATE TABLE IF NOT EXISTS sunbird.org_type(id text, name text, PRIMARY KEY (id));
CREATE INDEX inx_ot_name ON sunbird.org_type(name);

CREATE TABLE IF NOT EXISTS sunbird.org_mapping(id text, orgIdOne text,relation text,orgIdTwo text, PRIMARY KEY (id));
CREATE INDEX inx_om_orgIdOne ON sunbird.org_mapping(orgIdOne);
CREATE INDEX inx_om_orgIdTwo ON sunbird.org_mapping(orgIdTwo);

ALTER TABLE sunbird.user ADD rootOrgId text;
ALTER TABLE sunbird.address ADD addressLine1 text;
ALTER TABLE sunbird.address ADD addressLine2 text;
ALTER TABLE sunbird.user_education ADD degree text;

CREATE TABLE IF NOT EXISTS sunbird.master_action(id text, name text, PRIMARY KEY (id));
CREATE INDEX inx_ma_name ON sunbird.master_action(name);

CREATE TABLE IF NOT EXISTS sunbird.action_group(id text, actionId list<text>,groupName text, PRIMARY KEY (id));
CREATE INDEX inx_uacg_groupName ON sunbird.action_group(groupName);

CREATE TABLE IF NOT EXISTS sunbird.user_action_role(id text, actionGroupId list<text>,roleId text, PRIMARY KEY (id));
CREATE INDEX inx_uactr_roleId ON sunbird.user_action_role(roleId);


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
 insert into sunbird.role_group (id,name) values ('SYSTEM_ADMINISTRATION','System Administration');
 insert into sunbird.role_group (id,name) values ('ORG_MANAGEMENT','Org Management');
 insert into sunbird.role_group (id,name) values ('MEMBERSHIP_MANAGEMENT','Membership Management');
 insert into sunbird.role_group (id,name) values ('CONTENT_CREATION','Content Creation');
 insert into sunbird.role_group (id,name) values ('CONTENT_CURATION','Content Curation');
 insert into sunbird.role_group (id,name) values ('CONTENT_REVIEW','Content Review');

CREATE TABLE IF NOT EXISTS sunbird.role(id text, name text,roleGroupId List<text>,status int, PRIMARY KEY (id));
CREATE INDEX inx_ro_master_name ON sunbird.role(name);
 insert into sunbird.role (id,name,rolegroupid,status) values ('ADMIN','Admin',['SYSTEM_ADMINISTRATION','ORG_MANAGEMENT'],1);
 insert into sunbird.role (id,name,rolegroupid,status) values ('ORG_ADMIN','Org Admin',['ORG_MANAGEMENT','MEMBERSHIP_MANAGEMENT'],1);
 insert into sunbird.role (id,name,rolegroupid,status) values ('ORG_MODERATOR','Org Moderator',['MEMBERSHIP_MANAGEMENT'],1);
 insert into sunbird.role (id,name,rolegroupid,status) values ('CONTENT_CREATOR','Content Creator',['CONTENT_CREATION'],1);
 insert into sunbird.role (id,name,rolegroupid,status) values ('CONTENT_REVIEWER','Content Reviewer',['CONTENT_CREATION','CONTENT_CURATION','CONTENT_REVIEW'],1);

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
 insert into sunbird.url_action (id,name) values ('ORG_MANAGEMENT','Org Management');
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
creation of id= one way hash of (userId##courseId##batchId) here courseId is identifier of EkStep course
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

DROP INDEX IF EXISTS inx_uei_source;
ALTER TABLE sunbird.user_external_identity DROP source;
ALTER TABLE sunbird.user_external_identity ADD provider text;
ALTER TABLE sunbird.user_external_identity ADD externalIdValue text;
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

ALTER TABLE sunbird.user_org drop role;
ALTER TABLE sunbird.user_org ADD roles list<text>;

//to export data from csv to cassandra table run below command(for page_section and page_management table)
// change the path of csv file
//COPY sunbird.page_management(id, appmap,createdby ,createddate ,name ,organisationid ,portalmap ,updatedby ,updateddate ) FROM '/tmp/cql/pageMgmt.csv';

//COPY sunbird.page_section(id, alt,createdby ,createddate ,description ,display ,imgurl ,name,searchquery , sectiondatatype ,status , updatedby ,updateddate) FROM '/tmp/cql/pageSection.csv';

// insert default root organisation -- July 15,2017
ALTER TABLE sunbird.organisation ADD isDefault boolean;

ALTER TABLE sunbird.user_courses ADD leafNodesCount int;
// change organisation status field from text to int -- July 19,2017
drop index inx_org_status;
ALTER TABLE sunbird.organisation DROP status ;
ALTER TABLE sunbird.organisation ADD status int;
CREATE INDEX inx_org_status ON sunbird.organisation (status);
INSERT INTO sunbird.organisation(id , isRootOrg , isDefault, status) values('ORG_001' , true , true, 1);

// add isdeleted field to user table -- July 31,2017
ALTER TABLE sunbird.user ADD isDeleted boolean;

//added for course batch
CREATE TABLE IF NOT EXISTS sunbird.course_batch(id text, courseId text,courseCreator text,createdBy text,createdOn text,enrollmentType text,startDate text,endDate text,name text,description text,status int,lastUpdatedOn text,mentors List<text>,participants List<text>,createdFor List<text>,PRIMARY KEY (id));
CREATE INDEX inx_cou_bat_status ON sunbird.course_batch (status);
CREATE INDEX inx_cou_bat_courseId ON sunbird.course_batch (courseId);
CREATE INDEX inx_cou_bat_courseCreator ON sunbird.course_batch (courseCreator);
CREATE INDEX inx_cou_bat_createdBy ON sunbird.course_batch (createdBy);
CREATE INDEX inx_cou_bat_enrolmentType ON sunbird.course_batch (enrollmentType);
ALTER TABLE sunbird.course_batch DROP createdon;
ALTER TABLE sunbird.course_batch ADD createdDate text;
ALTER TABLE sunbird.course_batch DROP lastupdatedon;
ALTER TABLE sunbird.course_batch ADD updatedDate text;

ALTER TABLE sunbird.organisation add provider text;
ALTER TABLE sunbird.organisation DROP source;
//Id is courseId
CREATE TABLE IF NOT EXISTS sunbird.course_publish_status(id text,submitDate text,status int,PRIMARY KEY (id));

// convert data type of participants from List to map -- Aug 7,2017
ALTER TABLE sunbird.course_batch DROP participants;
ALTER TABLE sunbird.course_batch ADD participant map<text,boolean>;

ALTER TABLE sunbird.course_batch ADD courseAdditionalInfo map<text,text>;

// adding the batchId column to content consumption table -- Aug 8,2017
ALTER TABLE sunbird.content_consumption ADD batchId text;

CREATE TABLE IF NOT EXISTS sunbird.bulk_upload_process(id text, status int,data text,successResult text,failureResult text,uploadedBy text,uploadedDate text,processStartTime text,processEndTime text,ObjectType text,organisationId text, PRIMARY KEY (id));
CREATE INDEX inx_status ON sunbird.bulk_upload_process(status);
insert into sunbird.role_group (id,name) values ('COURSE_MENTOR','Course Mentor');
update sunbird.role_group set url_action_ids=['courseMentor'] where id='COURSE_MENTOR';

ALTER TABLE sunbird.course_batch ADD countIncrementStatus boolean;
ALTER TABLE sunbird.course_batch ADD countIncrementDate text;
ALTER TABLE sunbird.course_batch ADD countDecrementStatus boolean;
ALTER TABLE sunbird.course_batch ADD countDecrementDate text;

CREATE INDEX inx_org_provider ON sunbird.organisation (provider);
CREATE INDEX inx_org_externalId ON sunbird.organisation (externalId);

insert into sunbird.url_action (id,name) values ('orgupload','orgupload');
update sunbird.role_group set url_action_ids=['suspendOrg','suspendUser','orgupload'] where id='SYSTEM_ADMINISTRATION';
update sunbird.url_action set url=['/v1/org/suspend'] where id='suspendOrg';
update sunbird.url_action set url=['/v1/user/block'] where id='suspendUser';
update sunbird.url_action set url=['/v1/org/upload'] where id='orgupload';
insert into sunbird.role (id,name,rolegroupid,status) values ('COURSE_MENTOR','Course Mentor',['COURSE_MENTOR'],1);

// changes on Aug 16,2017
ALTER TABLE sunbird.organisation ADD slug text;
ALTER TABLE sunbird.organisation ADD hashTagId text;
ALTER TABLE sunbird.organisation ADD theme text;
ALTER TABLE sunbird.user_org ADD position text;
ALTER TABLE sunbird.course_batch ADD hashTagId text;
CREATE INDEX inx_cps_status ON sunbird.course_publish_status (status);
ALTER TABLE sunbird.user ADD location text;
ALTER TABLE sunbird.organisation ADD contactDetails map<text,text>;
insert into sunbird.role_group (id,name) values ('FLAG_REVIEWER ','Flag Reviewer');
insert into sunbird.url_action (id,name) values ('FLAG_REVIEWER','flag Review');
insert into sunbird.role (id,name,rolegroupid,status) values ('FLAG_REVIEWER','Flag Reviewer',['FLAG_REVIEWER'],1);
update sunbird.role_group set url_action_ids=['flagReview'] where id='FLAG_REVIEWER';
ALTER TABLE sunbird.organisation DROP contactdetails;
ALTER TABLE sunbird.organisation ADD contactdetail text;

//update course_batch set countdecrementstatus=false ,countincrementstatus=false where id in ('01231295903433523233', '01231300152093900880', '01231362610791219226', '012311485318971392184', '012311507396763648187', '01231446621414195215', '012311399697334272167', '012310182931898368117', '01231437156529766411', '0123143731552501769', '012315729890295808125', '01231515693522124824', '012315105801404416176', '012315113121030144181', '0123156336446914560', '0123152537517178880', '012311452395159552176', '012310182079651840116', '01231365904918118428', '012315115229880320201', '01231297804052070441', '01231295967369625632', '01231437649992908813', '01231298538289561658', '01231290682958643227', '012310176900218880115', '012311394333097984166', '012311400451145728168', '01231513667683942421', '012315115088601088183', '0123153123053158404', '01231363201368064027', '01231290412171264026', '0123151248760258560', '01231514986607411223', '012311580166266880203', '01231217800957952058', '01231304911540224098', '0123152769465384961', '012310190924496896119', '01231569596413542494', '01231299360593510461', '01231437480674099212', '012310195742662656126', '012311489586135040185', '01231298390404300857', '012311415973486592169', '01231298670022656060', '01231569429976678493', '01231294824787148831', '012310173385113600114', '01231385960518451255', '012315785629794304137', '01231296418316288037', '012310193544601600118', '012311447751262208177', '012311507213688832188', '01231437595463680010', '0123156778024960005', '012311505273479168186', '01231300602153369682', '01231298422152396859', '0123152820520222722', '012311511755972608189', '012315179912159232103', '012315751464787968136', '012315736241045504130', '01231288911727001615', '01231514371529113622', '01231366031184691229', '01231383864920473645', '012315107363119104182', '012311574182944768202', '01231516784369664088', '01231443633637785614', '01231300661683814481' );
insert into sunbird.role_group (id,name) values ('COURSE_ADMIN','Course Admin');
update sunbird.role_group set url_action_ids=['courseAdmin'] where id='COURSE_ADMIN';
insert into sunbird.role (id,name,rolegroupid,status) values ('COURSE_ADMIN','Course Admin',['COURSE_ADMIN'],1);
insert into sunbird.role_group (id,name) values ('COURSE_CREATOR','Course Creator');
update sunbird.role_group set url_action_ids=['courseCreator'] where id='COURSE_CREATOR';
insert into sunbird.role (id,name,rolegroupid,status) values ('COURSE_CREATOR','Course Creator',['COURSE_CREATOR'],1);
update sunbird.role_group set name='Flag Reviewer' where id='FLAG_REVIEWER';
//changes on Aug 29,2017
CREATE TABLE IF NOT EXISTS sunbird.badge(id text, name text, description text, isActive boolean, PRIMARY KEY (id));
CREATE TABLE IF NOT EXISTS sunbird.user_badge(id text, createdDate text, createdBy text, updatedDate text,updatedBy text,badgeTypeId text,receivedDate text,receiverId text,providerId text,providerName text,providerEmail text,providerPhone text,description text,validityDate int,expiryDate text,image text,isVerified boolean,isExpired boolean,isRevoked boolean,revocationReason text,revocationDate text,revokedBy text,verifiedBy text,verifiedDate text ,PRIMARY KEY (id));
 CREATE INDEX inx_usr_badg ON sunbird.user_badge (badgeTypeId);
 insert into sunbird.badge (id,name,description,isactive) values ('0123206539020943360','President''s Gold Medal','Gold medal provided by President',true);
 CREATE INDEX inx_usr_badg_receiverid ON sunbird.user_badge (receiverid);
CREATE INDEX inx_uei_externalIdValue ON sunbird.user_external_identity (externalIdValue);

//adding for report tracking
CREATE TABLE IF NOT EXISTS sunbird.report_tracking(id text, status int,type text,createdDate text,userId text,uploadedDate text,email text,fileUrl text,emailTryCount int, PRIMARY KEY (id));
CREATE INDEX inx_report_tracking_status ON sunbird.report_tracking(status);
CREATE INDEX inx_report_tracking_userId ON sunbird.report_tracking(userId);
ALTER TABLE sunbird.report_tracking ADD firstName text;
ALTER TABLE sunbird.report_tracking ADD batchId text;
ALTER TABLE sunbird.report_tracking ADD period text;
ALTER TABLE sunbird.report_tracking ADD data text;
insert into sunbird.role_group (id,name) values ('PUBLIC','Public');
update sunbird.role_group set url_action_ids=['public'] where id='PUBLIC';
insert into sunbird.role (id,name,rolegroupid,status) values ('PUBLIC','Public',['PUBLIC'],1);
ALTER TABLE sunbird.report_tracking ADD tryCount int;
ALTER TABLE sunbird.report_tracking DROP emailTryCount;
ALTER TABLE sunbird.report_tracking ADD updatedDate text;

//Changes on Aug 31st 2017
ALTER TABLE sunbird.report_tracking DROP batchId;
ALTER TABLE sunbird.report_tracking ADD resourceId text;

// adding fileFormat for dashboard metrics report tracking -- Sep 1,2017
ALTER TABLE sunbird.report_tracking ADD format text;

ALTER TABLE sunbird.user DROP aadhaarno;
update organisation set channel='ROOT_ORG' where id='ORG_001';

// Sept 18th 2017
ALTER TABLE sunbird.org_type ADD createdDate text;
ALTER TABLE sunbird.org_type ADD createdBy text;
ALTER TABLE sunbird.org_type ADD updatedDate text;
ALTER TABLE sunbird.org_type ADD updatedBy text;
//Adding table user_notes --Sep 13th 2017
CREATE TABLE IF NOT EXISTS sunbird.user_notes(id text, userId text, courseId text,
contentId text, title text, note text, tags list<text>, createdDate text, createdBy text,
updatedDate text, updatedBy text, isDeleted boolean, PRIMARY KEY (id));
CREATE INDEX inx_un_userId ON sunbird.user_notes(userId);
CREATE INDEX inx_un_courseId ON sunbird.user_notes(courseId);
CREATE INDEX inx_un_contentId ON sunbird.user_notes(contentId);
ALTER TABLE sunbird.user ADD createdBy text;

//Adding changes related to social media in user table
ALTER TABLE sunbird.user ADD webpages list<frozen <map<text,text>>>;
CREATE TABLE IF NOT EXISTS sunbird.media_type(id text, name text, PRIMARY KEY (id));

insert into media_type(id,name) values('fb', 'facebook');
insert into media_type(id,name) values('twitter','twitter');
insert into media_type(id,name) values('in','linkedin');
insert into media_type(id,name) values('blog','blog');
//Oct 12th
ALTER TABLE sunbird.user ADD tempPassword text;
ALTER TABLE sunbird.user ADD currentLoginTime text;
//Oct 18th
UPDATE sunbird.media_type SET name = 'Facebook' where id = 'fb';
UPDATE sunbird.media_type SET name = 'Twitter' where id = 'twitter';
UPDATE sunbird.media_type SET name = 'LinkedIn' where id = 'in';
UPDATE sunbird.media_type SET name = 'Blog' where id = 'blog';

ALTER TABLE sunbird.bulk_upload_process ADD retryCount int;

// userSkill table to store the user skills - Oct 18, 2017 ---
/*
creation of id = one way hash of (userId##skillnametolowercase)
*/
CREATE TABLE IF NOT EXISTS sunbird.user_skills(id text, userId  text, skillname text,skillnametolowercase text, addedby text, addedat text, endorsementcount int ,endorsers Map<text, text>, PRIMARY KEY (id));
CREATE INDEX inx_us_userId ON sunbird.user_skills(userId);

// skills table - Oct 18, 2017 ---
/*
creation of id = one way hash of (userId##skillnametolowercase)
*/
CREATE TABLE IF NOT EXISTS sunbird.skills(id text,skills list<text>, PRIMARY KEY (id));

//25th Oct
ALTER TABLE sunbird.organisation ADD orgTypeId text;

//Announcement apis -27th Oct
{% if (cassandra_cluster_size | int) > 1 %}
CREATE KEYSPACE IF NOT EXISTS sunbirdplugin WITH REPLICATION = { 'class' : 'NetworkTopologyStrategy', 'datacenter1' : 2 };
{% else %}
CREATE KEYSPACE IF NOT EXISTS sunbirdplugin WITH REPLICATION = {'class':'SimpleStrategy','replication_factor':1};
{% endif %}
//CREATE TYPE IF NOT EXISTS sunbirdplugin.attachment (id text,filename text,mimetype text);
CREATE TABLE sunbirdplugin.announcement (id text,userid text,sourceid text,details map<text, text>,links list<text>,attachments list<text>,target text,sentcount int,priority text,expiry text,status text,createddate text,updateddate text, PRIMARY KEY (id));
CREATE TABLE sunbirdplugin.attachment (id text,file text,filename text,mimetype text,createdby text,status text,createddate text, PRIMARY KEY (id));
CREATE TABLE sunbirdplugin.metrics (id text,userid text,announcementid text,activity text,channel text,createddate text, PRIMARY KEY (id));
CREATE TABLE sunbirdplugin.announcementtype (id text,rootorgid text,name text,status text,createddate text, PRIMARY KEY (id));
CREATE TABLE sunbirdplugin.announcementauth (id text,userid text,rootorgid text,permissions map<text, text>,status text,createddate text, PRIMARY KEY (id));

insert into sunbird.role_group (id,name) values ('ANNOUNCEMENT_SENDER','Announcement Sender');
update sunbird.role_group set url_action_ids=['Announcement Sender'] where id='ANNOUNCEMENT_SENDER';
insert into sunbird.role (id,name,rolegroupid,status) values ('ANNOUNCEMENT_SENDER','Announcement Sender',['ANNOUNCEMENT_SENDER'],1);

//mongodb import , env var is taken from group_vars
//COPY sunbird.user_notes(id, userid,courseid,contentid,title,note,tags,createddate,updateddate,isdeleted) FROM '/tmp/notes-{{env}}.csv';
//2nd Nov
CREATE TABLE IF NOT EXISTS sunbird.tenant_preference(id text,tenantName text,orgId text,role text, data text, PRIMARY KEY (id));
CREATE INDEX inx_tp_userId ON sunbird.tenant_preference(orgId);
ALTER TABLE sunbird.user ADD tcstatus text;
//CLIENT_INFO table for master key
CREATE TABLE IF NOT EXISTS sunbird.client_info(id text, clientname text, masterkey text, createddate text, updateddate text, PRIMARY KEY (id));
CREATE INDEX inx_ci_clientname ON sunbird.client_info(clientname);
// Geo Location - Oct 31,2017

ALTER TABLE sunbird.user ADD tcupdateddate text;

CREATE TABLE IF NOT EXISTS sunbird.geo_location(id text,locationName text,rootOrgId text,type text, createdDate  text,createdBy text,updatedDate text,updatedBy text,topicName text,topicId text, PRIMARY KEY (id));
CREATE INDEX inx_gl_rootOrgId ON sunbird.geo_location(rootOrgId);
ALTER TABLE sunbird.geo_location DROP topicId ;
ALTER TABLE sunbird.geo_location DROP topicName ;
ALTER TABLE sunbird.geo_location ADD topic text;
ALTER TABLE sunbird.geo_location DROP locationName ;
ALTER TABLE sunbird.geo_location ADD location text;
// 3rd Nov 2017
ALTER TABLE sunbird.organisation ADD locationId text;

ALTER TABLE sunbird.user ADD profileVisibility map<text,text>;

// 9th Nov 2017
ALTER TABLE sunbirdplugin.announcement DROP target ;
ALTER TABLE sunbirdplugin.announcement ADD target map<text, frozen<map<text ,frozen<list<text>>>>>;
//adding default one Skills.
insert into skills (id,skills) values ('001',['java']);
ALTER TABLE sunbird.user_skills drop endorsers;
ALTER TABLE sunbird.user_skills ADD endorsersList frozen<List<Map<text , text>>>;
// 16th Nov 2017
ALTER TABLE sunbird.user ADD emailVerified boolean;

// 23rd Nov 2017
ALTER TABLE sunbird.user ADD countryCode text;
CREATE TABLE IF NOT EXISTS sunbird.system_settings (id text ,field text ,value text ,PRIMARY KEY (id));

// Dec 5th 2017

ALTER TABLE sunbird.geo_location ADD userCount int;

insert into sunbird.system_settings (id,field,value) values ('phoneUnique','phoneUnique','false');
insert into sunbird.system_settings (id,field,value) values ('emailUnique','emailUnique','false');
// Dec 6th 2017
ALTER TABLE sunbird.geo_location ADD userCountTTL text;
// adding new column in client-info to save the channel
ALTER TABLE sunbird.client_info ADD channel text;
CREATE INDEX inx_ci_clientchannel ON sunbird.client_info(channel);
