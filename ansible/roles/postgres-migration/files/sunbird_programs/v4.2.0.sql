alter type programtype rename to _programtype;
CREATE TYPE programtype AS ENUM ('public', 'private', 'restricted');
alter table program rename column type to _type;
alter table program add type programtype;
update program set type = _type::text::programtype;
alter table program drop column _type;
drop type _programtype;
