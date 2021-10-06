ALTER TABLE program ADD COLUMN acceptedContents text[];
ALTER TABLE program ADD COLUMN rejectedContents text[];
ALTER TABLE program ADD COLUMN sourcingRejectedComments jsonb;
