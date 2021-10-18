UPDATE public.program SET
target_type = 'collections'::programtargettype WHERE
target_type IS NULL ;
