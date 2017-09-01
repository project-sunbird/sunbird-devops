copy sunbird.organisation(id,orgname,provider,createddate) to '{{csv_output_root_dir}}/{{item}}.csv' with HEADER=true;
