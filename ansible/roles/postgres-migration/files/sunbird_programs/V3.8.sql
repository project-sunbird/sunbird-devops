CREATE TYPE status AS ENUM ('Draft', 'Live', 'Unlisted', 'Retired');
CREATE TYPE programtype AS ENUM ('public', 'private');
CREATE TYPE nominationstatus AS ENUM ('Pending', 'Approved', 'Rejected', 'Initiated');
CREATE SEQUENCE nomination_id_seq;
CREATE SEQUENCE IF NOT EXISTS contentid_seq;
CREATE TABLE program
(
    program_id character varying COLLATE pg_catalog."default" NOT NULL,
    name character varying COLLATE pg_catalog."default",
    description text COLLATE pg_catalog."default",
    content_types text[] COLLATE pg_catalog."default",
    collection_ids text[] COLLATE pg_catalog."default",
    type programtype,
    startdate timestamp without time zone DEFAULT timezone('utc'::text, (CURRENT_DATE)::timestamp with time zone),
    enddate timestamp without time zone,
    nomination_enddate timestamp without time zone,
    shortlisting_enddate timestamp without time zone,
    content_submission_enddate timestamp without time zone,
    image character varying COLLATE pg_catalog."default",
    status status,
    slug character varying COLLATE pg_catalog."default",
    config jsonb,
    channel character varying COLLATE pg_catalog."default" DEFAULT 'DIKSHA'::character varying,
    template_id character varying COLLATE pg_catalog."default" DEFAULT 'template1'::character varying,
    rootorg_id character varying COLLATE pg_catalog."default",
    sourcing_org_name character varying COLLATE pg_catalog."default",
    createdby character varying COLLATE pg_catalog."default",
    createdon timestamp with time zone DEFAULT timezone('utc'::text, now()),
    updatedby character varying COLLATE pg_catalog."default",
    updatedon timestamp with time zone DEFAULT timezone('utc'::text, now()),
    guidelines_url text COLLATE pg_catalog."default",
    rolemapping json,
    targetprimarycategories jsonb,
    CONSTRAINT pk_program_id PRIMARY KEY (program_id)
);

CREATE TABLE nomination
(
    id integer NOT NULL DEFAULT nextval('nomination_id_seq'::regclass),
    program_id character varying COLLATE pg_catalog."default" NOT NULL,
    user_id character varying COLLATE pg_catalog."default" NOT NULL,
    organisation_id character varying COLLATE pg_catalog."default",
    status nominationstatus,
    content_types text[] COLLATE pg_catalog."default",
    collection_ids text[] COLLATE pg_catalog."default",
    feedback text COLLATE pg_catalog."default",
    rolemapping json,
    createdby character varying COLLATE pg_catalog."default",
    createdon timestamp with time zone DEFAULT timezone('utc'::text, now()),
    updatedby character varying COLLATE pg_catalog."default",
    updatedon timestamp with time zone,
    targetprimarycategories jsonb,
    CONSTRAINT pk_id PRIMARY KEY (id)
);

CREATE TYPE contenttypesenum AS ENUM ('TeachingMethod', 'PedagogyFlow', 'FocusSpot', 'LearningOutcomeDefinition', 'PracticeQuestionSet', 'CuriosityQuestionSet', 'MarkingSchemeRubric', 'ExplanationResource', 'ExperientialResource', 'ConceptMap', 'SelfAssess', 'ExplanationVideo', 'ClassroomTeachingVideo', 'ExplanationReadingMaterial', 'LearningActivity', 'PreviousBoardExamPapers', 'LessonPlanResource');

CREATE TABLE contenttypes (
    id int4 NOT NULL DEFAULT nextval('contentid_seq'::regclass),
    name varchar NOT NULL,
    value contenttypesenum NOT NULL,
    createdon timestamp with time zone DEFAULT timezone('utc'::text, now()),
    updatedon timestamp with time zone DEFAULT timezone('utc'::text, now()),
    PRIMARY KEY ("id")
);
INSERT INTO "public"."contenttypes" ("name", "value") VALUES ('Teaching Method', 'TeachingMethod');
INSERT INTO "public"."contenttypes" ("name", "value") VALUES ('Pedagogy Flow', 'PedagogyFlow');
INSERT INTO "public"."contenttypes" ("name", "value") VALUES ('Focus Spot', 'FocusSpot');
INSERT INTO "public"."contenttypes" ("name", "value") VALUES ('Learning Outcome Definition', 'LearningOutcomeDefinition');
INSERT INTO "public"."contenttypes" ("name", "value") VALUES ('Practice Question Set', 'PracticeQuestionSet');
INSERT INTO "public"."contenttypes" ("name", "value") VALUES ('Curiosity Question Set', 'CuriosityQuestionSet');
INSERT INTO "public"."contenttypes" ("name", "value") VALUES ('Marking Scheme Rubric', 'MarkingSchemeRubric');
INSERT INTO "public"."contenttypes" ("name", "value") VALUES ('Explanation Resource', 'ExplanationResource');
INSERT INTO "public"."contenttypes" ("name", "value") VALUES ('Experiential Resource', 'ExperientialResource');
INSERT INTO "public"."contenttypes" ("name", "value") VALUES ('Concept Map', 'ConceptMap');
INSERT INTO "public"."contenttypes" ("name", "value") VALUES ('Self Assess', 'SelfAssess');
INSERT INTO "public"."contenttypes" ("name", "value") VALUES ('Explanation Video', 'ExplanationVideo');
INSERT INTO "public"."contenttypes" ("name", "value") VALUES ('Classroom Teaching Video', 'ClassroomTeachingVideo');
INSERT INTO "public"."contenttypes" ("name", "value") VALUES ('Explanation Reading Material', 'ExplanationReadingMaterial');
INSERT INTO "public"."contenttypes" ("name", "value") VALUES ('Activity for Learning', 'LearningActivity');
INSERT INTO "public"."contenttypes" ("name", "value") VALUES ('Previous Board Exam Papers', 'PreviousBoardExamPapers');
INSERT INTO "public"."contenttypes" ("name", "value") VALUES ('Lesson Plan', 'LessonPlanResource');


CREATE SEQUENCE IF NOT EXISTS configurationid_seq;
CREATE TYPE configurationstatus AS ENUM ('active', 'inactive');
CREATE TABLE configuration (
	id int4 NOT NULL DEFAULT nextval('configurationid_seq'::regclass),
	key varchar NOT NULL,
	value VARCHAR NOT NULL,
    status configurationstatus,
    createdby character varying COLLATE pg_catalog."default",
    createdon timestamp with time zone DEFAULT timezone('utc'::text, now()),
    updatedby character varying COLLATE pg_catalog."default",
    updatedon timestamp with time zone DEFAULT timezone('utc'::text, now()),
	PRIMARY KEY ("id")
);
INSERT INTO "public"."configuration" ("key", "value", "status") VALUES ('smsNominationAccept', 'VidyaDaan: Your nomination for $projectName is accepted. Please login to $url to start contributing content.', 'active');
INSERT INTO "public"."configuration" ("key", "value", "status") VALUES ('smsNominationReject', 'VidyaDaan: Your nomination for $projectName has not been accepted. Thank you for your interest. Please login to $url for details.', 'active');
INSERT INTO "public"."configuration" ("key", "value", "status") VALUES ('smsContentRequestedChanges', 'VidyaDaan: Your Content $contentName has not been accepted by your organization upon review. Please login to $url for details.', 'active');
INSERT INTO "public"."configuration" ("key", "value", "status") VALUES ('smsContentReject', 'VidyaDaan: Your Content $contentName has not been approved by the project owner. Please login to $url for details.', 'active');
INSERT INTO "public"."configuration" ("key", "value", "status") VALUES ('smsContentAccept', 'VidyaDaan: Your Content $contentName for the project $projectName has been approved by the project owner.', 'active');
INSERT INTO "public"."configuration" ("key", "value", "status") VALUES ('contentVideoSize', 15360, 'active');
INSERT INTO "public"."configuration" ("key", "value", "status") VALUES ('projectFeedDays', 3, 'active');
INSERT INTO "public"."configuration" ("key", "value", "status") VALUES ('smsContentAcceptWithChanges', 'VidyaDaan: Your Content $contentName for the project $projectName has been approved by the project owner with few changes.', 'active');
INSERT INTO "public"."configuration" ("key", "value", "status") VALUES ('overrideMetaData', '[{"code":"name","dataType":"text","editable":true},{"code":"learningOutcome","dataType":"list","editable":true},{"code":"attributions","dataType":"list","editable":false},{"code":"copyright","dataType":"text","editable":false},{"code":"creator","dataType":"text","editable":false},{"code":"license","dataType":"list","editable":false},{"code":"contentPolicyCheck","dataType":"boolean","editable":false}]', 'active');

CREATE SEQUENCE user_program_preference_id_seq;
CREATE TABLE public.user_program_preference
(
    id integer NOT NULL DEFAULT nextval('user_program_preference_id_seq'::regclass),
    user_id character varying COLLATE pg_catalog."default" NOT NULL,
    program_id character varying COLLATE pg_catalog."default" NOT NULL,
    contributor_preference json,
    sourcing_preference json,
    createdby text COLLATE pg_catalog."default",
    updatedby text COLLATE pg_catalog."default",
    createdon timestamp without time zone DEFAULT timezone('utc'::text, now()),
    updatedon timestamp without time zone DEFAULT timezone('utc'::text, now()),
    CONSTRAINT user_program_preference_pkey PRIMARY KEY (user_id, program_id)
);


-- Sprint 12
CREATE INDEX "idx_program_rootorgid_status" ON "public"."program" USING BTREE ("rootorg_id", "status");
CREATE INDEX "pk_program_status_type" ON "public"."program" USING BTREE ("status", "type");
CREATE INDEX "pk_program_updatedon" ON "public"."program" USING BTREE (updatedon DESC);
CREATE INDEX "idx_nomination_updatedon" ON "public"."nomination" USING BTREE (updatedon DESC);
CREATE INDEX "idx_nomination_userid" ON "public"."nomination" (user_id);
CREATE INDEX "idx_nomination_programid" ON "public"."nomination" USING BTREE (program_id);

-- Sprint 14

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS bulk_job_id_seq;
CREATE TYPE bulk_job_status AS ENUM ('processing', 'completed', 'failed');
CREATE TYPE bulk_job_type AS ENUM ('bulk_upload', 'bulk_approval');
-- Table Definition
CREATE TABLE bulk_job_request (
    id int4 NOT NULL DEFAULT nextval('bulk_job_id_seq'::regclass),
    process_id varchar NOT NULL UNIQUE,
    program_id varchar NOT NULL,
    collection_id varchar,
    org_id varchar,
    status bulk_job_status,
    type bulk_job_type,
    overall_stats jsonb,
    data jsonb,
    err_message text,
    createdby varchar,
    updatedby varchar,
    createdon timestamptz DEFAULT timezone('utc'::text, now()),
    updatedon timestamptz NOT NULL DEFAULT timezone('utc'::text, now()),
    completedon timestamp,
    expiration timestamp,
    PRIMARY KEY (id, process_id)
);
-- Indices
CREATE INDEX "pk_bulk_job_request_createdon" ON "public"."bulk_job_request" USING BTREE (createdon DESC);
