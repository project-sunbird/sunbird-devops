CREATE TYPE status AS ENUM ('Draft', 'Live');
CREATE TYPE programtype AS ENUM ('public', 'private');
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
    config text COLLATE pg_catalog."default" NOT NULL,
    channel character varying COLLATE pg_catalog."default" DEFAULT 'DIKSHA'::character varying,
    template_id character varying COLLATE pg_catalog."default" DEFAULT 'template1'::character varying,
    rootorg_id character varying COLLATE pg_catalog."default",
    sourcing_org_name character varying COLLATE pg_catalog."default",
    createdby character varying COLLATE pg_catalog."default",
    createdon timestamp with time zone DEFAULT timezone('utc'::text, now()),
    updatedby character varying COLLATE pg_catalog."default",
    updatedon timestamp with time zone DEFAULT timezone('utc'::text, now()),
    CONSTRAINT pk_program_id PRIMARY KEY (program_id)
)

CREATE TYPE nominationstatus AS ENUM ('Pending', 'Approved', 'Rejected');
CREATE SEQUENCE nomination_id_seq;
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
    CONSTRAINT pk_id PRIMARY KEY (id)
)

CREATE SEQUENCE IF NOT EXISTS contentid_seq;
CREATE TYPE contenttypesenum AS ENUM ('TeachingMethod', 'PedagogyFlow', 'FocusSpot', 'LearningOutcomeDefinition', 'PracticeQuestionSet', 'CuriosityQuestionSet', 'MarkingSchemeRubric', 'ExplanationResource', 'ExperientialResource', 'ConceptMap', 'SelfAssess');
CREATE TABLE contenttypes (
    id int4 NOT NULL DEFAULT nextval('contentid_seq'::regclass),
    name varchar NOT NULL,
    value contenttypesenum NOT NULL,
    createdon timestamp with time zone DEFAULT timezone('utc'::text, now()),
    updatedon timestamp with time zone DEFAULT timezone('utc'::text, now()),
    PRIMARY KEY ("id")
);
INSERT INTO contenttypes ("name", "value") VALUES ('Teaching Method', 'TeachingMethod');
INSERT INTO contenttypes ("name", "value") VALUES ('Pedagogy Flow', 'PedagogyFlow');
INSERT INTO contenttypes ("name", "value") VALUES ('Focus Spot', 'FocusSpot');
INSERT INTO contenttypes ("name", "value") VALUES ('Learning Outcome Definition', 'LearningOutcomeDefinition');
INSERT INTO contenttypes ("name", "value") VALUES ('Practice Question Set', 'PracticeQuestionSet');
INSERT INTO contenttypes ("name", "value") VALUES ('Curiosity Question Set', 'CuriosityQuestionSet');
INSERT INTO contenttypes ("name", "value") VALUES ('Marking Scheme Rubric', 'MarkingSchemeRubric');
INSERT INTO contenttypes ("name", "value") VALUES ('Explanation Resource', 'ExplanationResource');
INSERT INTO contenttypes ("name", "value") VALUES ('Experiential Resource', 'ExperientialResource');
INSERT INTO contenttypes ("name", "value") VALUES ('Concept Map', 'ConceptMap');
INSERT INTO contenttypes ("name", "value") VALUES ('Self Assess', 'SelfAssess');

ALTER TYPE contenttypesenum ADD VALUE 'ExplanationVideo';
ALTER TYPE contenttypesenum ADD VALUE 'ClassroomTeachingVideo';
ALTER TYPE contenttypesenum ADD VALUE 'ExplanationReadingMaterial';
ALTER TYPE contenttypesenum ADD VALUE 'LearningActivity';
ALTER TYPE contenttypesenum ADD VALUE 'PreviousBoardExamPapers';
ALTER TYPE contenttypesenum ADD VALUE 'LessonPlanResource';
INSERT INTO "public"."contenttypes" (name, value) VALUES ('Explanation Video', 'ExplanationVideo');
INSERT INTO "public"."contenttypes" (name, value) VALUES ('Classroom Teaching Video', 'ClassroomTeachingVideo');
INSERT INTO "public"."contenttypes" (name, value) VALUES ('Explanation Reading Material', 'ExplanationReadingMaterial');
INSERT INTO "public"."contenttypes" (name, value) VALUES ('Learning Activity', 'LearningActivity');
INSERT INTO "public"."contenttypes" (name, value) VALUES ('Previous Board Exam Papers', 'PreviousBoardExamPapers');
INSERT INTO "public"."contenttypes" (name, value) VALUES ('Lesson Plan', 'LessonPlanResource');

ALTER TYPE nominationstatus ADD VALUE 'Initiated';
ALTER TABLE public.program ADD COLUMN guidelines_url TEXT;
ALTER TABLE public.program ADD COLUMN rolemapping json;

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

### DIKSHA EMAIL TemplATES
INSERT INTO sunbird.email_template (name, template)
VALUES ('emailNominationAccept', '<!doctype html><head> <meta name="viewport" content="width=device-width"> <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"> <title></title> <style> @media screen and (min-width: 320px) { .container { width: 100%; font-family: sans-serif; font-size: 14px; display: block; Margin: 0 auto; background: #fff; max-width: initial; padding: 25px; } body { background: #fff !important; } td, p { font-size: 15px !important; } } @media screen and (min-width: 767px) { .container { max-width: 580px; padding: 8px 25px; width: 580px !important; margin-top: 25px !important; } body { background-color: #f6f6f6 !important; } } </style></head><body style="background-color: #f6f6f6; font-family: sans-serif; -webkit-font-smoothing: antialiased; font-size: 14px; line-height: 1.7; margin: 0; padding: 0; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;"> <div class="container"> <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td><img src="https://vdn.diksha.gov.in/tenant/ntp/logo.png" alt="logo" align="right" width="180" max-width="100%" style="padding-top: 15px;"> </td> </tr> <tr> <td style="font-family: sans-serif; font-size: 14px; font-weight: normal; margin-bottom: 15px;line-height: 1.7;padding:10px 0"> Hi,</td> </tr> <tr> <td> <p style="font-family: sans-serif; font-size: 14px; font-weight: normal;margin-bottom: 15px;line-height: 1.7;"> This is to inform you that your nomination for the project $orgName has been accepted. You can start contributing content for this project. Please ensure that the content you contribute is relevant to the project needs, is as per the Content Policy and is submitted as per the timelines given in the project details. </p> </td> </tr> <tr> <td> <p style="font-family: sans-serif; font-size: 14px; font-weight: normal; margin-bottom: 15px;line-height: 1.7;"> All your content will undergo review and will be accepted or rejected based on its relevance and quality. The final decision lies with the project owner. </p> </td> </tr> <tr> <td> <div style="font-family: sans-serif; font-size: 14px; font-weight: normal;line-height: 1.7;"> Regards, </div> <div style="font-family: sans-serif; font-size: 14px; font-weight: normal;margin-bottom: 15px;line-height: 1.7;"> VidyaDaan Team </div> </td> </tr> <tr> <td> <p style="font-family: sans-serif; font-size: 14px; font-weight: normal; margin: 0; Margin-bottom: 15px;line-height: 1.7;"> Note: This is an automatically generated email. Replies to this mailbox will not be monitored. If you are not the intended recipient of this message, or need to communicate with the team, write to <a href="mailto:vdnsupport@teamdiksha.org">vdnsupport@teamdiksha.org</a> </p> </td> </tr> </table> </div></body></html>')
INSERT INTO sunbird.email_template (name, template)
VALUES ('emailNominationReject', '<!doctype html><head> <meta name="viewport" content="width=device-width"> <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"> <title></title> <style> @media screen and (min-width: 320px) { .container { width: 100%; font-family: sans-serif; font-size: 14px; display: block; Margin: 0 auto; background: #fff; max-width: initial; padding: 25px; } body { background: #fff !important; } td, p { font-size: 15px !important; } } @media screen and (min-width: 767px) { .container { max-width: 580px; padding: 8px 25px; width: 580px !important; margin-top: 25px !important; } body { background-color: #f6f6f6 !important; } } </style></head><body style="background-color: #f6f6f6; font-family: sans-serif; -webkit-font-smoothing: antialiased; font-size: 14px; line-height: 1.7; margin: 0; padding: 0; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;"> <div class="container"> <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td><img src="https://vdn.diksha.gov.in/tenant/ntp/logo.png" alt="logo" align="right" width="180" max-width="100%" style="padding-top: 15px;"> </td> </tr> <tr> <td style="font-family: sans-serif; font-size: 14px; font-weight: normal; margin-bottom: 15px;line-height: 1.7;padding:10px 0"> Hi,</td> </tr> <tr> <td> <p style="font-family: sans-serif; font-size: 14px; font-weight: normal;margin-bottom: 15px;line-height: 1.7;"> This is to inform you that your nomination for the project $orgName has not been accepted. Please login to <a href="https://vdn.diksha.gov.in/" target="_blank">https://vdn.diksha.gov.in/</a> for details. </p> </td> </tr> <tr> <td> <p style="font-family: sans-serif; font-size: 14px; font-weight: normal; margin-bottom: 15px;line-height: 1.7;"> Thank you for your interest. You can nominate yourself / your organisation for other projects that are currently open for nomination, or for future projects. </p> </td> </tr> <tr> <td> <div style="font-family: sans-serif; font-size: 14px; font-weight: normal;line-height: 1.7;"> Regards, </div> <div style="font-family: sans-serif; font-size: 14px; font-weight: normal; margin-bottom: 15px;line-height: 1.7;"> VidyaDaan Team </div> </td> </tr> <tr> <td> <p style="font-family: sans-serif; font-size: 14px; font-weight: normal; margin: 0; Margin-bottom: 15px;line-height: 1.7;"> Note: This is an automatically generated email. Replies to this mailbox will not be monitored. If you are not the intended recipient of this message, or need to communicate with the team, write to <a href="mailto:vdnsupport@teamdiksha.org">vdnsupport@teamdiksha.org</a> </p> </td> </tr> </table> </div></body></html>')
INSERT INTO sunbird.email_template (name, template)
VALUES ('emailContentRequestedChanges', '<!doctype html> <head> <meta name="viewport" content="width=device-width"> <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"> <title></title> <style> @media screen and (min-width: 320px) { .container { width: 100%; font-family: sans-serif; font-size: 14px; display: block; Margin: 0 auto; background: #fff; max-width: initial; padding: 25px; } body { background: #fff !important; } td, p { font-size: 15px !important; } } @media screen and (min-width: 767px) { .container { max-width: 580px; padding: 8px 25px; width: 580px !important; margin-top: 25px !important; } body { background-color: #F6F6F6 !important; } } </style> </head> <body style="background-color: #F6F6F6; font-family: sans-serif; -webkit-font-smoothing: antialiased; font-size: 14px; line-height: 1.7; margin: 0; padding: 0; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;"> <div class="container"> <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td><img src="https://vdn.diksha.gov.in/tenant/ntp/logo.png" alt="logo" align="right" width="180" max-width="100%" style="padding-top: 15px;"> </td> </tr> <tr> <td style="font-family: sans-serif; font-size: 14px; font-weight: normal; margin-bottom: 15px;line-height: 1.7;padding:10px 0"> Hi,</td> </tr> <tr> <td> <p style="font-family: sans-serif; font-size: 14px; font-weight: normal;margin-bottom: 15px;line-height: 1.7;"> This is to inform you that your content $contentName contributed to the project $projectName has not been accepted by your organization upon review. Please login to <a href="https://vdn.diksha.gov.in/">https://vdn.diksha.gov.in/</a> for details. </p> </td> </tr> <tr> <td> <div style="font-family: sans-serif; font-size: 14px; font-weight: normal;line-height: 1.7;"> Regards, </div> <div style="font-family: sans-serif; font-size: 14px; font-weight: normal;margin-bottom: 15px;line-height: 1.7;"> VidyaDaan Team </div> </td> </tr> <tr> <td> <p style="font-family: sans-serif; font-size: 14px; font-weight: normal; margin: 0; Margin-bottom: 15px;line-height: 1.7;"> Note: This is an automatically generated email. Replies to this mailbox will not be monitored. If you are not the intended recipient of this message, or need to communicate with the team, write to <a href="mailto:vdnsupport@teamdiksha.org">vdnsupport@teamdiksha.org</a> </p> </td> </tr> </table> </div> </body> </html>')
INSERT INTO sunbird.email_template (name, template)
VALUES ('emailContentReject', '<!doctype html> <head> <meta name="viewport" content="width=device-width"> <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"> <title></title> <style> @media screen and (min-width: 320px) { .container { width: 100%; font-family: sans-serif; font-size: 14px; display: block; Margin: 0 auto; background: #fff; max-width: initial; padding: 25px; } body { background: #fff !important; } td, p { font-size: 15px !important; } } @media screen and (min-width: 767px) { .container { max-width: 580px; padding: 8px 25px; width: 580px !important; margin-top: 25px !important; } body { background-color: #F6F6F6 !important; } } </style> </head> <body style="background-color: #F6F6F6; font-family: sans-serif; -webkit-font-smoothing: antialiased; font-size: 14px; line-height: 1.7; margin: 0; padding: 0; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;"> <div class="container"> <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td><img src="https://vdn.diksha.gov.in/tenant/ntp/logo.png" alt="logo" align="right" width="180" max-width="100%" style="padding-top: 15px;"> </td> </tr> <tr> <td style="font-family: sans-serif; font-size: 14px; font-weight: normal; margin-bottom: 15px;line-height: 1.7;padding:10px 0"> Hi,</td> </tr> <tr> <td> <p> This is to inform you that your content $contentName contributed to the project $projectName has not been approved by the project owner. Please login to <a href="https://vdn.diksha.gov.in/">https://vdn.diksha.gov.in/</a> for details. </p> </td> </tr> <tr> <td> <div style="font-family: sans-serif; font-size: 14px; font-weight: normal;line-height: 1.7;"> Regards, </div> <div style="font-family: sans-serif; font-size: 14px; font-weight: normal;margin-bottom: 15px;line-height: 1.7;"> VidyaDaan Team </div> </td> </tr> <tr> <td> <p style="font-family: sans-serif; font-size: 14px; font-weight: normal; margin: 0; Margin-bottom: 15px;line-height: 1.7;"> Note: This is an automatically generated email. Replies to this mailbox will not be monitored. If you are not the intended recipient of this message, or need to communicate with the team, write to <a href="mailto:vdnsupport@teamdiksha.org">vdnsupport@teamdiksha.org</a> </p> </td> </tr> </table> </div> </body> </html>')
INSERT INTO sunbird.email_template (name, template)
VALUES ('emailContentAccept', '<!doctype html> <head> <meta name="viewport" content="width=device-width"> <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"> <title></title> <style> @media screen and (min-width: 320px) { .container { width: 100%; font-family: sans-serif; font-size: 14px; display: block; Margin: 0 auto; background: #fff; max-width: initial; padding: 25px; } body { background: #fff !important; } td, p { font-size: 15px !important; } } @media screen and (min-width: 767px) { .container { max-width: 580px; padding: 8px 25px; width: 580px !important; margin-top: 25px !important; } body { background-color: #F6F6F6 !important; } } </style> </head> <body style="background-color: #F6F6F6; font-family: sans-serif; -webkit-font-smoothing: antialiased; font-size: 14px; line-height: 1.7; margin: 0; padding: 0; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;"> <div class="container"> <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td><img src="https://vdn.diksha.gov.in/tenant/ntp/logo.png" alt="logo" align="right" width="180" max-width="100%" style="padding-top: 15px;"> </td> </tr> <tr> <td style="font-family: sans-serif; font-size: 14px; font-weight: normal; margin-bottom: 15px;line-height: 1.7;padding:10px 0"> Hi,</td> </tr> <tr> <td> <p> This is to inform you that your content $contentName contributed to the project $projectName has been approved by the project owner. </p> </td> </tr> <tr> <td> <div style="font-family: sans-serif; font-size: 14px; font-weight: normal;line-height: 1.7;"> Regards, </div> <div style="font-family: sans-serif; font-size: 14px; font-weight: normal;margin-bottom: 15px;line-height: 1.7;"> VidyaDaan Team </div> </td> </tr> <tr> <td> <p style="font-family: sans-serif; font-size: 14px; font-weight: normal; margin: 0; Margin-bottom: 15px;line-height: 1.7;"> Note: This is an automatically generated email. Replies to this mailbox will not be monitored. If you are not the intended recipient of this message, or need to communicate with the team, write to <a href="mailto:vdnsupport@teamdiksha.org">vdnsupport@teamdiksha.org</a> </p> </td> </tr> </table> </div> </body> </html>')

UPDATE public.contenttypes SET name='Activity for Learning' WHERE value='LearningActivity';
UPDATE public.nomination SET organisation_id=SUBSTRING(organisation_id, 3) WHERE organisation_id LIKE '1-%';

UPDATE sunbird.email_template SET template='<!doctype html><head> <meta name="viewport" content="width=device-width"> <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"> <title></title> <style>@media screen and (min-width: 320px){.container{width: 100%; font-family: sans-serif; font-size: 14px; display: block; Margin: 0 auto; background: #fff; max-width: initial; padding: 25px;}body{background: #fff !important;}td, p{font-size: 15px !important;}}@media screen and (min-width: 767px){.container{max-width: 580px; padding: 8px 25px; width: 580px !important; margin-top: 25px !important;}body{background-color: #f6f6f6 !important;}}</style></head><body style="background-color: #f6f6f6; font-family: sans-serif; -webkit-font-smoothing: antialiased; font-size: 14px; line-height: 1.7; margin: 0; padding: 0; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;"> <div class="container"> <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td><img src="$baseUrl/tenant/ntp/logo.png" alt="logo" align="right" width="180" max-width="100%" style="padding-top: 15px;"> </td></tr><tr> <td style="font-family:sans-serif;font-size:14px;font-weight:normal;margin-bottom:15px;line-height:1.7;padding:10px 0">Hi,</td></tr><tr> <td> <p style="font-family:sans-serif;font-size:14px;font-weight:normal;margin-bottom:15px;line-height:1.7">This is to inform you that your nomination for the project $projectName has been accepted. You can start contributing content for this project. Please ensure that the content you contribute is relevant to the project needs, is as per the Content Policy and is submitted as per the timelines given in the project details. </p></td></tr><tr> <td> <p style="font-family:sans-serif;font-size:14px;font-weight:normal;margin-bottom:15px;line-height:1.7"> If you are a <strong>contributing organization,</strong> please follow the steps mentioned below to contribute:</p><ul style="font-family:sans-serif;font-size:14px;font-weight:normal;margin-bottom:15px;line-height:1.7"> <li> Step 1: Admin has to invite users of your organization to sign in to the system and assign them the role of contributors and reviewers;<i> Please watch “How to invite contributors and reviewers” video in this link: <a href="$baseUrl/contribute/help" target="_blank">$baseUrl/contribute/help</a></i> </li><li> Step 2: Users with the contributor role will have to upload content; <i>Please watch “How to contribute content as a contributor of an organization” video in this link: <a href="$baseUrl/contribute/help" target="_blank">$baseUrl/contribute/help</a></i> </li><li> Step 3: Users with the reviewer role will have to perform the internal review before the content can be sent for the final review to the sourcing organization;<i> Please watch “How to review content as a reviewer of an organization” video in this link: <a href="$baseUrl/contribute/help" target="_blank">$baseUrl/contribute/help</a></i> </li></ul> <p style="font-family:sans-serif;font-size:14px;font-weight:normal;margin-bottom:15px;line-height:1.7">Contributing organizations are requested to share the above videos with their contributors and reviewers. </p><p style="font-family:sans-serif;font-size:14px;font-weight:normal;margin-bottom:15px;line-height:1.7"> If you are an <strong>individual contributor,</strong> <i>please watch “How to contribute content as a individual contribute” video in this link: <a href="$baseUrl/contribute/help" target="_blank">$baseUrl/contribute/help</a></i> </p></td></tr><tr> <td> <p style="font-family:sans-serif;font-size:14px;font-weight:normal;margin-bottom:15px;line-height:1.7"> All your content will undergo review and will be accepted or rejected based on its relevance and quality. The final decision lies with the project owner. </p></td></tr><tr> <td> <div style="font-family:sans-serif;font-size:14px;font-weight:normal;line-height:1.7"> Regards,</div><div style="font-family:sans-serif;font-size:14px;font-weight:normal;margin-bottom:15px;line-height:1.7">VidyaDaan Team </div></td></tr><tr> <td> <p style="font-family:sans-serif;font-size:14px;font-weight:normal;margin:0;Margin-bottom:15px;line-height:1.7">Note: This is an automatically generated email. Replies to this mailbox will not be monitored. If you are not the intended recipient of this message, or need to communicate with the team, write to <a href="mailto:vdnsupport@teamdiksha.org" target="_blank">vdnsupport@teamdiksha.org</a> </p></td></tr></tbody> </table> </div></body></html>' WHERE name='emailNominationAccept';

UPDATE sunbird.email_template SET template='<!doctype html><head> <meta name="viewport" content="width=device-width"> <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"> <title></title> <style>@media screen and (min-width: 320px){.container{width: 100%; font-family: sans-serif; font-size: 14px; display: block; Margin: 0 auto; background: #fff; max-width: initial; padding: 25px;}body{background: #fff !important;}td, p{font-size: 15px !important;}}@media screen and (min-width: 767px){.container{max-width: 580px; padding: 8px 25px; width: 580px !important; margin-top: 25px !important;}body{background-color: #f6f6f6 !important;}}</style></head><body style="background-color: #f6f6f6; font-family: sans-serif; -webkit-font-smoothing: antialiased; font-size: 14px; line-height: 1.7; margin: 0; padding: 0; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;"> <div class="container"> <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td><img src="$baseUrl/tenant/ntp/logo.png" alt="logo" align="right" width="180" max-width="100%" style="padding-top: 15px;"> </td></tr><tr> <td style="font-family: sans-serif; font-size: 14px; font-weight: normal; margin-bottom: 15px;line-height: 1.7;padding:10px 0"> Hi,</td></tr><tr> <td> <p style="font-family: sans-serif; font-size: 14px; font-weight: normal;margin-bottom: 15px;line-height: 1.7;"> This is to inform you that your nomination for the project $projectName has not been accepted. Please login to <a href="$baseUrl/" target="_blank">$baseUrl/</a> for details. </p></td></tr><tr> <td> <p style="font-family: sans-serif; font-size: 14px; font-weight: normal; margin-bottom: 15px;line-height: 1.7;"> Thank you for your interest. You can nominate yourself / your organisation for other projects that are currently open for nomination, or for future projects. </p></td></tr><tr> <td> <div style="font-family: sans-serif; font-size: 14px; font-weight: normal;line-height: 1.7;"> Regards, </div><div style="font-family: sans-serif; font-size: 14px; font-weight: normal; margin-bottom: 15px;line-height: 1.7;"> VidyaDaan Team </div></td></tr><tr> <td> <p style="font-family: sans-serif; font-size: 14px; font-weight: normal; margin: 0; Margin-bottom: 15px;line-height: 1.7;"> Note: This is an automatically generated email. Replies to this mailbox will not be monitored. If you are not the intended recipient of this message, or need to communicate with the team, write to <a href="mailto:vdnsupport@teamdiksha.org" target="_blank">vdnsupport@teamdiksha.org</a> </p></td></tr></table> </div></body></html>' WHERE name='emailNominationReject';


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
)

-- Sprint 11

ALTER TYPE status ADD VALUE 'Unlisted';
ALTER TYPE status ADD VALUE 'Retired';

-- Sprint 12
INSERT INTO "public"."configuration" ("key", "value", "status") VALUES ('contentVideoSize', 15360, 'active');
CREATE INDEX "idx_program_rootorgid_status" ON "public"."program" USING BTREE ("rootorg_id", "status");
CREATE INDEX "pk_program_status_type" ON "public"."program" USING BTREE ("status", "type");
CREATE INDEX "pk_program_updatedon" ON "public"."program" USING BTREE (updatedon DESC);
CREATE INDEX "idx_nomination_updatedon" ON "public"."nomination" USING BTREE (updatedon DESC);
CREATE INDEX "idx_nomination_userid" ON "public"."nomination" (user_id);
CREATE INDEX "idx_nomination_programid" ON "public"."nomination" USING BTREE (program_id);
ALTER TABLE program ALTER COLUMN config TYPE jsonb USING config::jsonb;

-- Sprint 14

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS bulk_job_id_seq;
DROP TYPE IF EXISTS "public"."bulk_job_status";
CREATE TYPE "public"."bulk_job_status" AS ENUM ('processing', 'completed', 'failed');
DROP TYPE IF EXISTS "public"."bulk_job_type";
CREATE TYPE "public"."bulk_job_type" AS ENUM ('bulk_upload', 'bulk_approval');
-- Table Definition
CREATE TABLE "public"."bulk_job_request" (
    "id" int4 NOT NULL DEFAULT nextval('bulk_job_id_seq'::regclass),
    "process_id" varchar NOT NULL UNIQUE,
    "program_id" varchar NOT NULL,
    "collection_id" varchar,
    "org_id" varchar,
    "status" "public"."bulk_job_status",
    "type" "public"."bulk_job_type",
    "overall_stats" jsonb,
    "data" jsonb,
    "err_message" text,
    "createdby" varchar,
    "updatedby" varchar,
    "createdon" timestamptz DEFAULT timezone('utc'::text, now()),
    "updatedon" timestamptz NOT NULL DEFAULT timezone('utc'::text, now()),
    "completedon" timestamp,
    "expiration" timestamp,
    PRIMARY KEY ("id","process_id")
);
-- Indices
CREATE INDEX "pk_bulk_job_request_createdon" ON "public"."bulk_job_request" USING BTREE (createdon DESC);


-- Sprint 15
INSERT INTO "public"."configuration" ("key", "value", "status") VALUES ('projectFeedDays', 3, 'active');
INSERT INTO "public"."configuration" ("key", "value", "status") VALUES ('smsContentAcceptWithChanges', 'VidyaDaan: Your Content $contentName for the project $projectName has been approved by the project owner with few changes.', 'active');
INSERT INTO "public"."configuration" ("key", "value", "status") VALUES ('overrideMetaData', '[{"code":"name","dataType":"text","editable":true},{"code":"learningOutcome","dataType":"list","editable":true},{"code":"attributions","dataType":"list","editable":false},{"code":"copyright","dataType":"text","editable":false},{"code":"creator","dataType":"text","editable":false},{"code":"license","dataType":"list","editable":false},{"code":"contentPolicyCheck","dataType":"boolean","editable":false}]', 'active');
### DIKSHA EMAIL TemplATES
INSERT INTO sunbird.email_template (name, template)
VALUES ('emailContentAcceptWithChanges', '<!doctype html> <head> <meta name="viewport" content="width=device-width"> <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"> <title></title> <style> @media screen and (min-width: 320px) { .container { width: 100%; font-family: sans-serif; font-size: 14px; display: block; Margin: 0 auto; background: #fff; max-width: initial; padding: 25px; } body { background: #fff !important; } td, p { font-size: 15px !important; } } @media screen and (min-width: 767px) { .container { max-width: 580px; padding: 8px 25px; width: 580px !important; margin-top: 25px !important; } body { background-color: #F6F6F6 !important; } } </style> </head> <body style="background-color: #F6F6F6; font-family: sans-serif; -webkit-font-smoothing: antialiased; font-size: 14px; line-height: 1.7; margin: 0; padding: 0; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;"> <div class="container"> <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td><img src="https://vdn.diksha.gov.in/tenant/ntp/logo.png" alt="logo" align="right" width="180" max-width="100%" style="padding-top: 15px;"> </td> </tr> <tr> <td style="font-family: sans-serif; font-size: 14px; font-weight: normal; margin-bottom: 15px;line-height: 1.7;padding:10px 0"> Hi,</td> </tr> <tr> <td> <p> This is to inform you that your content $contentName contributed to the project $projectName has been approved by the project owner with few changes. </p> </td> </tr> <tr> <td> <div style="font-family: sans-serif; font-size: 14px; font-weight: normal;line-height: 1.7;"> Regards, </div> <div style="font-family: sans-serif; font-size: 14px; font-weight: normal;margin-bottom: 15px;line-height: 1.7;"> VidyaDaan Team </div> </td> </tr> <tr> <td> <p style="font-family: sans-serif; font-size: 14px; font-weight: normal; margin: 0; Margin-bottom: 15px;line-height: 1.7;"> Note: This is an automatically generated email. Replies to this mailbox will not be monitored. If you are not the intended recipient of this message, or need to communicate with the team, write to <a href="mailto:vdnsupport@teamdiksha.org">vdnsupport@teamdiksha.org</a> </p> </td> </tr> </table> </div> </body> </html>')
