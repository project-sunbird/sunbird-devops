 find jobs -type f -name config.xml -exec sed -i 's/cassandra-cluster/${public_repo_branch}/g' {} \;
 find . -type f -name config.xml -exec sed -i 's/cassandra-cluster/${public_repo_branch}/g' {} \;
 find . -type f -name config.xml -exec sed -i 's/release-1.15/${public_repo_branch}/g' {} \;
 find . -type f -name config.xml -exec sed -i 's/release-1.14-S3/${public_repo_branch}/g' {} \;
 find . -type f -name config.xml -exec sed -i 's/release-1.14.0-S3/${public_repo_branch}/g' {} \;
 find . -type f -name config.xml -exec sed -i 's/refactored-dev-deploy/${public_repo_branch}/g' {} \;
 find . -type f -name config.xml -exec sed -i 's/release-1.14-sp3/${public_repo_branch}/g' {} \;
 find . -type f -name config.xml -exec sed -i 's/keycloak-deployment/${public_repo_branch}/g' {} \;
 find . -type f -name config.xml -exec sed -i 's/release-1.14.1/${public_repo_branch}/g' {} \;
 find . -type f -name config.xml -exec sed -i 's/secor-0.24/${public_repo_branch}/g' {} \;
 find . -type f -name config.xml -exec sed -i 's/\*\/${public_repo_branch}/${public_repo_branch}/g' {} \;
 find . -type f -name config.xml -exec sed -i 's/release-1.14-sprint3/${public_repo_branch}/g' {} \;
 find . -type f -name config.xml -exec sed -i 's/release-1.14/${public_repo_branch}/g' {} \;
 find . -type f -name config.xml -exec sed -i 's/keycloak-deployment/${public_repo_branch}/g' {} \;
 find . -type f -name config.xml -exec sed -i 's/keycloak\-deployment/${public_repo_branch}/g' {} \;
 find . -type f -name config.xml -exec sed -i 's/definition-update/${public_repo_branch}/g' {} \;
 find . -type f -name config.xml -exec sed -i 's/neo4j-${public_repo_branch}/neo4j-definition-update/g' {} \;
 rm -rf OpsAdministration/jobs/dev/jobs/Core/jobs/KeyRotation
 rm -rf OpsAdministration/jobs/dev/jobs/DataPipeline/jobs/KeyRotation/
 rm -rf OpsAdministration/jobs/dev/jobs/KnowledgePlatform/jobs/KeyRotation
 rm -rf /deploy/jqlsenkins/jobs/OpsAdministration/jobs/dev/jobs/Core/jobs/KeyRotation
 rm -rf OpsAdministration/jobs/dev/jobs/Core/jobs/KeyRotation/
