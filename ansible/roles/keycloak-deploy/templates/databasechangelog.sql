--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.20
-- Dumped by pg_dump version 12.6 (Ubuntu 12.6-0ubuntu0.20.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

--
-- Name: databasechangelog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.databasechangelog (
    id character varying(255) NOT NULL,
    author character varying(255) NOT NULL,
    filename character varying(255) NOT NULL,
    dateexecuted timestamp without time zone NOT NULL,
    orderexecuted integer NOT NULL,
    exectype character varying(10) NOT NULL,
    md5sum character varying(35),
    description character varying(255),
    comments character varying(255),
    tag character varying(255),
    liquibase character varying(20),
    contexts character varying(255),
    labels character varying(255)
);


ALTER TABLE public.databasechangelog OWNER TO postgres;

--
-- Data for Name: databasechangelog; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.databasechangelog (id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, comments, tag, liquibase, contexts, labels) FROM stdin;
1.0.0.Final	sthorger@redhat.com	META-INF/jpa-changelog-1.0.0.Final.xml	2021-03-05 15:06:41.36859	1	EXECUTED	7:00a57f7a6fb456639b34e62972e0ec02	createTable (x29), addPrimaryKey (x21), addUniqueConstraint (x9), addForeignKeyConstraint (x32)		\N	3.4.1	\N	\N
1.0.0.Final	sthorger@redhat.com	META-INF/db2-jpa-changelog-1.0.0.Final.xml	2021-03-05 15:06:41.468003	2	MARK_RAN	7:f061c3934594ee60a9b2343f5100ae4e	createTable (x29), addPrimaryKey (x21), addUniqueConstraint (x6), addForeignKeyConstraint (x30)		\N	3.4.1	\N	\N
1.1.0.Beta1	sthorger@redhat.com	META-INF/jpa-changelog-1.1.0.Beta1.xml	2021-03-05 15:06:41.569055	3	EXECUTED	7:0310eb8ba07cec616460794d42ade0fa	delete (x3), createTable (x3), addColumn (x5), addPrimaryKey (x3), addForeignKeyConstraint (x3), customChange		\N	3.4.1	\N	\N
1.1.0.Final	sthorger@redhat.com	META-INF/jpa-changelog-1.1.0.Final.xml	2021-03-05 15:06:41.609154	4	EXECUTED	7:5d25857e708c3233ef4439df1f93f012	renameColumn		\N	3.4.1	\N	\N
1.2.0.Beta1	psilva@redhat.com	META-INF/jpa-changelog-1.2.0.Beta1.xml	2021-03-05 15:06:41.814296	5	EXECUTED	7:c7a54a1041d58eb3817a4a883b4d4e84	delete (x4), createTable (x8), addColumn (x2), addPrimaryKey (x6), addForeignKeyConstraint (x9), addUniqueConstraint (x2), addColumn, dropForeignKeyConstraint (x2), dropUniqueConstraint, renameColumn (x3), addUniqueConstraint, addForeignKeyConstra...		\N	3.4.1	\N	\N
1.2.0.Beta1	psilva@redhat.com	META-INF/db2-jpa-changelog-1.2.0.Beta1.xml	2021-03-05 15:06:41.84295	6	MARK_RAN	7:2e01012df20974c1c2a605ef8afe25b7	delete (x4), createTable (x8), addColumn (x2), addPrimaryKey (x6), addForeignKeyConstraint (x9), addUniqueConstraint (x2), addColumn, dropForeignKeyConstraint (x2), dropUniqueConstraint, renameColumn (x3), customChange, dropForeignKeyConstraint, d...		\N	3.4.1	\N	\N
1.2.0.RC1	bburke@redhat.com	META-INF/jpa-changelog-1.2.0.CR1.xml	2021-03-05 15:06:42.016634	7	EXECUTED	7:0f08df48468428e0f30ee59a8ec01a41	delete (x5), createTable (x3), addColumn, createTable (x4), addPrimaryKey (x7), addForeignKeyConstraint (x6), renameColumn, addColumn (x2), update, dropColumn, dropForeignKeyConstraint, renameColumn, addForeignKeyConstraint, dropForeignKeyConstrai...		\N	3.4.1	\N	\N
1.2.0.RC1	bburke@redhat.com	META-INF/db2-jpa-changelog-1.2.0.CR1.xml	2021-03-05 15:06:42.036555	8	MARK_RAN	7:a77ea2ad226b345e7d689d366f185c8c	delete (x5), createTable (x3), addColumn, createTable (x4), addPrimaryKey (x7), addForeignKeyConstraint (x6), renameColumn, addUniqueConstraint, addColumn (x2), update, dropColumn, dropForeignKeyConstraint, renameColumn, addForeignKeyConstraint, r...		\N	3.4.1	\N	\N
1.2.0.Final	keycloak	META-INF/jpa-changelog-1.2.0.Final.xml	2021-03-05 15:06:42.052587	9	EXECUTED	7:a3377a2059aefbf3b90ebb4c4cc8e2ab	update (x3)		\N	3.4.1	\N	\N
1.3.0	bburke@redhat.com	META-INF/jpa-changelog-1.3.0.xml	2021-03-05 15:06:42.325442	10	EXECUTED	7:04c1dbedc2aa3e9756d1a1668e003451	delete (x6), createTable (x7), addColumn, createTable, addColumn (x2), update, dropDefaultValue, dropColumn, addColumn, update (x4), addPrimaryKey (x4), dropPrimaryKey, dropColumn, addPrimaryKey (x4), addForeignKeyConstraint (x8), dropDefaultValue...		\N	3.4.1	\N	\N
1.4.0	bburke@redhat.com	META-INF/jpa-changelog-1.4.0.xml	2021-03-05 15:06:42.483346	11	EXECUTED	7:36ef39ed560ad07062d956db861042ba	delete (x7), addColumn (x5), dropColumn, renameTable (x2), update (x10), createTable (x3), customChange, dropPrimaryKey, addPrimaryKey (x4), addForeignKeyConstraint (x2), dropColumn, addColumn		\N	3.4.1	\N	\N
1.4.0	bburke@redhat.com	META-INF/db2-jpa-changelog-1.4.0.xml	2021-03-05 15:06:42.492642	12	MARK_RAN	7:d909180b2530479a716d3f9c9eaea3d7	delete (x7), addColumn (x5), dropColumn, renameTable, dropForeignKeyConstraint, renameTable, addForeignKeyConstraint, update (x10), createTable (x3), customChange, dropPrimaryKey, addPrimaryKey (x4), addForeignKeyConstraint (x2), dropColumn, addCo...		\N	3.4.1	\N	\N
1.5.0	bburke@redhat.com	META-INF/jpa-changelog-1.5.0.xml	2021-03-05 15:06:42.621045	13	EXECUTED	7:cf12b04b79bea5152f165eb41f3955f6	delete (x7), dropDefaultValue, dropColumn, addColumn (x3)		\N	3.4.1	\N	\N
1.6.1_from15	mposolda@redhat.com	META-INF/jpa-changelog-1.6.1.xml	2021-03-05 15:06:42.694045	14	EXECUTED	7:7e32c8f05c755e8675764e7d5f514509	addColumn (x3), createTable (x2), addPrimaryKey (x2)		\N	3.4.1	\N	\N
1.6.1_from16-pre	mposolda@redhat.com	META-INF/jpa-changelog-1.6.1.xml	2021-03-05 15:06:42.699234	15	MARK_RAN	7:980ba23cc0ec39cab731ce903dd01291	delete (x2)		\N	3.4.1	\N	\N
1.6.1_from16	mposolda@redhat.com	META-INF/jpa-changelog-1.6.1.xml	2021-03-05 15:06:42.704126	16	MARK_RAN	7:2fa220758991285312eb84f3b4ff5336	dropPrimaryKey (x2), addColumn, update, dropColumn, addColumn, update, dropColumn, addPrimaryKey (x2)		\N	3.4.1	\N	\N
1.6.1	mposolda@redhat.com	META-INF/jpa-changelog-1.6.1.xml	2021-03-05 15:06:42.710028	17	EXECUTED	7:d41d8cd98f00b204e9800998ecf8427e	Empty		\N	3.4.1	\N	\N
1.7.0	bburke@redhat.com	META-INF/jpa-changelog-1.7.0.xml	2021-03-05 15:06:42.823133	18	EXECUTED	7:91ace540896df890cc00a0490ee52bbc	createTable (x5), addColumn (x2), dropDefaultValue, dropColumn, addPrimaryKey, addForeignKeyConstraint, addPrimaryKey, addForeignKeyConstraint, addPrimaryKey, addForeignKeyConstraint, addPrimaryKey, addForeignKeyConstraint (x2), addUniqueConstrain...		\N	3.4.1	\N	\N
1.8.0	mposolda@redhat.com	META-INF/jpa-changelog-1.8.0.xml	2021-03-05 15:06:42.913937	19	EXECUTED	7:c31d1646dfa2618a9335c00e07f89f24	addColumn, createTable (x3), dropNotNullConstraint, addColumn (x2), createTable, addPrimaryKey, addUniqueConstraint, addForeignKeyConstraint (x5), addPrimaryKey, addForeignKeyConstraint (x2), addPrimaryKey, addForeignKeyConstraint, update		\N	3.4.1	\N	\N
1.8.0-2	keycloak	META-INF/jpa-changelog-1.8.0.xml	2021-03-05 15:06:42.922416	20	EXECUTED	7:df8bc21027a4f7cbbb01f6344e89ce07	dropDefaultValue, update		\N	3.4.1	\N	\N
1.8.0	mposolda@redhat.com	META-INF/db2-jpa-changelog-1.8.0.xml	2021-03-05 15:06:42.928866	21	MARK_RAN	7:f987971fe6b37d963bc95fee2b27f8df	addColumn, createTable (x3), dropNotNullConstraint, addColumn (x2), createTable, addPrimaryKey, addUniqueConstraint, addForeignKeyConstraint (x5), addPrimaryKey, addForeignKeyConstraint (x2), addPrimaryKey, addForeignKeyConstraint, update		\N	3.4.1	\N	\N
1.8.0-2	keycloak	META-INF/db2-jpa-changelog-1.8.0.xml	2021-03-05 15:06:42.934903	22	MARK_RAN	7:df8bc21027a4f7cbbb01f6344e89ce07	dropDefaultValue, update		\N	3.4.1	\N	\N
1.9.0	mposolda@redhat.com	META-INF/jpa-changelog-1.9.0.xml	2021-03-05 15:06:42.970223	23	EXECUTED	7:ed2dc7f799d19ac452cbcda56c929e47	update (x9), customChange, dropForeignKeyConstraint (x2), dropUniqueConstraint, dropTable, dropForeignKeyConstraint (x2), dropTable, dropForeignKeyConstraint (x2), dropUniqueConstraint, dropTable, createIndex		\N	3.4.1	\N	\N
1.9.1	keycloak	META-INF/jpa-changelog-1.9.1.xml	2021-03-05 15:06:42.980533	24	EXECUTED	7:80b5db88a5dda36ece5f235be8757615	modifyDataType (x3)		\N	3.4.1	\N	\N
1.9.1	keycloak	META-INF/db2-jpa-changelog-1.9.1.xml	2021-03-05 15:06:42.984178	25	MARK_RAN	7:1437310ed1305a9b93f8848f301726ce	modifyDataType (x2)		\N	3.4.1	\N	\N
1.9.2	keycloak	META-INF/jpa-changelog-1.9.2.xml	2021-03-05 15:06:43.028395	26	EXECUTED	7:b82ffb34850fa0836be16deefc6a87c4	createIndex (x11)		\N	3.4.1	\N	\N
authz-2.0.0	psilva@redhat.com	META-INF/jpa-changelog-authz-2.0.0.xml	2021-03-05 15:06:43.150937	27	EXECUTED	7:9cc98082921330d8d9266decdd4bd658	createTable, addPrimaryKey, addUniqueConstraint, createTable, addPrimaryKey, addForeignKeyConstraint, addUniqueConstraint, createTable, addPrimaryKey, addForeignKeyConstraint, addUniqueConstraint, createTable, addPrimaryKey, addForeignKeyConstrain...		\N	3.4.1	\N	\N
authz-2.5.1	psilva@redhat.com	META-INF/jpa-changelog-authz-2.5.1.xml	2021-03-05 15:06:43.16034	28	EXECUTED	7:03d64aeed9cb52b969bd30a7ac0db57e	update		\N	3.4.1	\N	\N
2.1.0	bburke@redhat.com	META-INF/jpa-changelog-2.1.0.xml	2021-03-05 15:06:43.240094	29	EXECUTED	7:e01599a82bf8d6dc22a9da506e22e868	createTable (x11), addPrimaryKey (x11), addForeignKeyConstraint (x2)		\N	3.4.1	\N	\N
2.2.0	bburke@redhat.com	META-INF/jpa-changelog-2.2.0.xml	2021-03-05 15:06:43.263381	30	EXECUTED	7:53188c3eb1107546e6f765835705b6c1	addColumn, createTable (x2), modifyDataType, addForeignKeyConstraint (x2)		\N	3.4.1	\N	\N
2.3.0	bburke@redhat.com	META-INF/jpa-changelog-2.3.0.xml	2021-03-05 15:06:43.288995	31	EXECUTED	7:d6e6f3bc57a0c5586737d1351725d4d4	createTable, addPrimaryKey, dropDefaultValue, dropColumn, addColumn (x2), customChange, dropColumn (x4), addColumn		\N	3.4.1	\N	\N
2.4.0	bburke@redhat.com	META-INF/jpa-changelog-2.4.0.xml	2021-03-05 15:06:43.297139	32	EXECUTED	7:454d604fbd755d9df3fd9c6329043aa5	customChange		\N	3.4.1	\N	\N
2.5.0	bburke@redhat.com	META-INF/jpa-changelog-2.5.0.xml	2021-03-05 15:06:43.304803	33	EXECUTED	7:57e98a3077e29caf562f7dbf80c72600	customChange, modifyDataType		\N	3.4.1	\N	\N
2.5.0-unicode-oracle	hmlnarik@redhat.com	META-INF/jpa-changelog-2.5.0.xml	2021-03-05 15:06:43.312148	34	MARK_RAN	7:e4c7e8f2256210aee71ddc42f538b57a	modifyDataType (x13), addColumn, sql, dropColumn, renameColumn, modifyDataType (x2)		\N	3.4.1	\N	\N
2.5.0-unicode-other-dbs	hmlnarik@redhat.com	META-INF/jpa-changelog-2.5.0.xml	2021-03-05 15:06:43.347881	35	EXECUTED	7:09a43c97e49bc626460480aa1379b522	modifyDataType (x5), dropUniqueConstraint, modifyDataType (x3), addUniqueConstraint, dropPrimaryKey, modifyDataType, addNotNullConstraint, addPrimaryKey, modifyDataType (x5), dropUniqueConstraint, modifyDataType, addUniqueConstraint, modifyDataType		\N	3.4.1	\N	\N
2.5.0-duplicate-email-support	slawomir@dabek.name	META-INF/jpa-changelog-2.5.0.xml	2021-03-05 15:06:43.378984	36	EXECUTED	7:26bfc7c74fefa9126f2ce702fb775553	addColumn		\N	3.4.1	\N	\N
2.5.0-unique-group-names	hmlnarik@redhat.com	META-INF/jpa-changelog-2.5.0.xml	2021-03-05 15:06:43.38735	37	EXECUTED	7:a161e2ae671a9020fff61e996a207377	addUniqueConstraint		\N	3.4.1	\N	\N
2.5.1	bburke@redhat.com	META-INF/jpa-changelog-2.5.1.xml	2021-03-05 15:06:43.395994	38	EXECUTED	7:37fc1781855ac5388c494f1442b3f717	addColumn		\N	3.4.1	\N	\N
3.0.0	bburke@redhat.com	META-INF/jpa-changelog-3.0.0.xml	2021-03-05 15:06:43.412321	39	EXECUTED	7:13a27db0dae6049541136adad7261d27	addColumn		\N	3.4.1	\N	\N
3.2.0	keycloak	META-INF/jpa-changelog-3.2.0.xml	2021-03-05 15:06:43.591686	40	EXECUTED	7:21de72ee56f1c0c861b883ac5b37c850	addColumn, dropPrimaryKey, dropColumn, addPrimaryKey, createTable, addPrimaryKey, addForeignKeyConstraint, createIndex (x45)		\N	3.4.1	\N	\N
\.


--
-- PostgreSQL database dump complete
--

