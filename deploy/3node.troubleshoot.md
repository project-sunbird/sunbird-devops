# Guide for basic troubleshooting
> Caution: Don't stop the stop the db machine without stopping all dbs manually, else there can be data corruption.
1. While installing some step failed.
    1. re running the installation script will fix the problem on most cases.
2. Default username and password for keycloak is `admin` `admin`  
   For security reasons Keycloak is only exposed in private network  
   Refer to change password: [change the username and password](https://www.keycloak.org/docs/latest/server_admin/index.html#server-initialization)
3. All kong admin operations can be done against `<core-ip>:12000/admin-api/`  
   for example, To get consumer key and secret to create jwt token from kong:
    ```
    curl http://localhost:12000/admin-api/consumers/<name>/jwt
    ```
