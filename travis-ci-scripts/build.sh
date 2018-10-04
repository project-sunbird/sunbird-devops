fail=0
echo "Building $release"
./travis-ci-scripts/update_config.sh
./travis-ci-scripts/launch_vm.sh
./travis-ci-scripts/copy_script.sh
if [[ $? -ne 0 ]]; then
   fail=1
fi
./travis-ci-scripts/remove_vm.sh

if [[ $fail -eq 1 ]]; then
   echo "Sunbird installation for $release failed"
   exit 1
fi
