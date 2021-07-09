INSERT INTO "public"."configuration" ("key", "value", "status") VALUES ('programTargetObjectMap', '[{"identifier":"obj-cat:content-playlist_collection_all","name":"Content Playlist","targetObjectType":"Collection","associatedAssetTypes":["Content"],"contentAdditionMode":["Search"]},{"identifier":"obj-cat:demo-practice-question-set_questionset_all","name":"Demo Practice Question Set","targetObjectType":"QuestionSet","associatedAssetTypes":["Question","QuestionSet"],"contentAdditionMode":["New"]},{"identifier":"obj-cat:digital-textbook_collection_all","name":"Digital Textbook","targetObjectType":"Collection","associatedAssetTypes":["Content"],"contentAdditionMode":["Search"]},{"identifier":"obj-cat:professional-development-course_collection_all","name":"Course","targetObjectType":"Collection","associatedAssetTypes":["Content"],"contentAdditionMode":["Search"]},{"identifier":"obj-cat:question-paper_collection_all","name":"Question paper","targetObjectType":"Collection","associatedAssetTypes":["Content"],"contentAdditionMode":["Search"]}]', 'active');
ALTER TABLE program ADD COLUMN targetCollectionPrimaryCategories jsonb;
CREATE TYPE programTargetType AS ENUM ('collections', 'searchCriteria');
ALTER TABLE program ADD COLUMN target_type programTargetType;
