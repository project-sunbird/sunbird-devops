# Using scripts:

- All the scripts are using the github api's.
- All the scripts will take github.csv file as input and read each line to get the values of all variables
- First udpate github.csv file row wise and run the scripts
- In github.csv there are 4 variables with comma seperated 

     REPO_NAME,BRANCH_NAME,MERGE_ACCESS_USERS(;),CHECKS
     
     MERGE_ACCESS_USERS and CHECKS: These variables are required only by disableBranchProtection.sh script.
