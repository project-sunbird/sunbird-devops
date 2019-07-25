import json

from keycloak import KeycloakOpenID
from keycloak import KeycloakAdmin
import urllib2, argparse, json

# Create client
def keycloak_create_client(config):
    data = json.load(open(config['keycloak_clients']))
    
    # Get the existing clients
    keycloak_admin.realm_name = config['keycloak_realm']    
    clients = keycloak_admin.get_clients()
    
    # 1. Read the clients to be added from json
    # 2. Check if client already exists in keycloak
    # 3. Add the client if not exist
    for rec in data['clients']:
        client_exist_falg = 0
        for client in clients:
            if rec['clientId'] == client['clientId']:
                client_exist_falg = 1
                break
        if (client_exist_falg == 0):
            keycloak_admin.create_client(rec)
            print rec['clientId'] + " client created"
        else :
            print rec['clientId'] + " client already exist"

if  __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Configure keycloak user apis')
    parser.add_argument('keycloak_bootstrap_config', help='configuration json file that is needed for keycloak bootstrap')
    args = parser.parse_args()

    with open(args.keycloak_bootstrap_config) as keycloak_bootstrap_config:
        config = json.load(keycloak_bootstrap_config)

    try:
        # Get access token
        keycloak_admin = KeycloakAdmin(server_url=config['keycloak_auth_server_url'],
                            username=config['keycloak_management_user'],
                            password=config['keycloak_management_password'],
                            realm_name="master",
                            client_id='admin-cli',
                            verify=False)
        

        # Create clients
        keycloak_create_client(config)

    except urllib2.HTTPError as e:
        error_message = e.read()
        print(error_message)
        raise
