import json

from keycloak import KeycloakOpenID
from keycloak import KeycloakAdmin
import urllib2, argparse, json

# Import realm
def keycloak_import_realm(keycloak_realm_file):
    data = json.load(open(keycloak_realm_file))
    realm_import = keycloak_admin.import_realm(data)

# Add user and set password
def keycloak_create_user(email, username, firstName, lastName, password):
    new_user = keycloak_admin.create_user({"email": email,
                    "username": username,
                    "emailVerified": True,
                    "enabled": True,
                    "firstName": firstName,
                    "lastName": lastName,
                    "credentials": [{"value": "12345","type": password}],
                    "realmRoles": ["user_default"]})

# Create the user and assign the role to access the user management API
def update_user_roles(config):
    realm_json = json.load(open(config['keycloak_realm_json_file_path']))
    clientId = "realm-management"

    for client in realm_json['clients']:
        if clientId == client['clientId']:
            client_id = client["id"]
            break

    user = keycloak_admin.get_users({"username":config['keycloak_api_management_username']})
    user_id = user[0]['id'];

    # Read the role from file
    with open(config['keycloak_user_manager_roles_json_file_path'], 'r') as data_file:
        json_data = data_file.read()

    roles = json.loads(json_data)
    keycloak_admin.assign_client_role(user_id, client_id, roles)


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
        # Import realm
        keycloak_import_realm(config['keycloak_realm_json_file_path'])

        # Set realm name to sunbird
        keycloak_admin.realm_name = config['keycloak_realm']

        # Add user for user api
        keycloak_create_user(email=config['keycloak_api_management_user_email'],
            username=config['keycloak_api_management_username'],
            firstName=config['keycloak_api_management_user_first_name'],
            lastName=config['keycloak_api_management_user_last_name'],
            password=config['keycloak_api_management_user_password'])

        # Update user roles for access user management API's
        update_user_roles(config)

    except urllib2.HTTPError as e:
        error_message = e.read()
        print error_message
        raise
