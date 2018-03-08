### Badger Dockerfile

1. All steps except creating a superuser is automated.
    for that
    ``` 
      docker exec -it <container-name> sh
      code/manager.py createsuperuser
    ```
2. Settings.py contains DB configurations, please update it

2a. Database schema creation using settings.py will happen while creation of the image,

so please make sure that your db is accessible. 

Note: If in future, you want to change the db ip,

you'll have to go inside the container and change the ip, or better mount the config location.

3. Running example:
    
    docker build -t openbadger .

    docker run -p 8000:8000 -d openbadger:latest 
