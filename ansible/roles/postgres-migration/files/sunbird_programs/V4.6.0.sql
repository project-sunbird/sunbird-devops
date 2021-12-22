CREATE TYPE formstatus AS ENUM ('Active', 'Inactive');
CREATE TABLE public.formdata (
    id character varying NOT NULL,
    channel character varying,
    objecttype character varying,
    primarycategory character varying,
    context character varying,
    context_type character varying,
    operation character varying,
    data jsonb,
    status public.formstatus,
    createdon timestamp without time zone,
    updatedon timestamp without time zone,
    createdby character varying,
    updatedby character varying,
    CONSTRAINT unique_form_data PRIMARY KEY (channel, objecttype, primarycategory, context, context_type, operation)
);
