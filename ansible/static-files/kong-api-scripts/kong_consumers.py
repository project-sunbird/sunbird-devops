import urllib2, argparse, json
import jwt

from common import json_request

def _consumer_exists(kong_admin_api_url, username):
    consumers_url = "{}/consumers".format(kong_admin_api_url)
    try:
        urllib2.urlopen(consumers_url + "/" + username)
        return True
    except urllib2.HTTPError as e:
        if(e.code == 404):
            return False
        else:
            raise

def _ensure_consumer_exists(kong_admin_api_url, consumer):
    username = consumer['username']
    consumers_url = "{}/consumers".format(kong_admin_api_url)
    if(not _consumer_exists(kong_admin_api_url, username)):
        print("Adding consumer {}".format(username));
        json_request("POST", consumers_url, {'username': username})


def save_consumers(kong_admin_api_url, consumers, kong_credentials_file_path):
    consumers_url = "{}/consumers".format(kong_admin_api_url)
    consumers_to_be_present = [consumer for consumer in consumers if consumer['state'] == 'present']
    consumers_to_be_absent = [consumer for consumer in consumers if consumer['state'] == 'absent']

    for consumer in consumers_to_be_present:
        username = consumer['username']
        _ensure_consumer_exists(kong_admin_api_url, consumer)
        _save_groups_for_consumer(kong_admin_api_url, consumer)
        jwt_credential = _get_first_or_create_jwt_credential(kong_admin_api_url, consumer)
        credential_algorithm = jwt_credential['algorithm']
        if credential_algorithm == 'HS256':
            jwt_token = jwt.encode({'iss': jwt_credential['key']}, jwt_credential['secret'], algorithm=credential_algorithm)
            print("JWT token for {} is : {}".format(username, jwt_token))
        if 'save_credentials' in consumer:
            _save_credentials_to_a_file(jwt_credential, kong_credentials_file_path)

    for consumer in consumers_to_be_absent:
        username = consumer['username']
        if(_consumer_exists(kong_admin_api_url, username)):
            print("Deleting consumer {}".format(username));
            json_request("DELETE", consumers_url + "/" + username, "")


def _get_first_or_create_jwt_credential(kong_admin_api_url, consumer):
    username = consumer["username"]
    credential_algorithm = consumer.get('credential_algorithm', 'HS256')
    consumer_jwt_credentials_url = kong_admin_api_url + "/consumers/" + username + "/jwt"
    saved_credentials_details = json.loads(urllib2.urlopen(consumer_jwt_credentials_url).read())
    saved_credentials = saved_credentials_details["data"]
    saved_credentials_for_algorithm = [saved_credential for saved_credential in saved_credentials if saved_credential['algorithm'] == credential_algorithm]
    if(len(saved_credentials_for_algorithm) > 0):
        print("Updating credentials for consumer {} for algorithm {}".format(username, credential_algorithm));
        this_credential = saved_credentials_for_algorithm[0]
        credential_data = {
            "rsa_public_key": consumer.get('credential_rsa_public_key', this_credential.get("rsa_public_key", '')),
            "key": consumer.get('credential_iss', this_credential['key'])
        }
        this_credential_url = "{}/{}".format(consumer_jwt_credentials_url, this_credential["id"])
        response = json_request("PATCH", this_credential_url, credential_data)
        jwt_credential = json.loads(response.read())
        return jwt_credential
    else:
        print("Creating jwt credentials for consumer {}".format(username));
        credential_data = {
            "algorithm": credential_algorithm,
        }
        if 'credential_rsa_public_key' in consumer:
            credential_data["rsa_public_key"] = consumer['credential_rsa_public_key']
        if 'credential_iss' in consumer:
            credential_data["key"] = consumer['credential_iss']
        response = json_request("POST", consumer_jwt_credentials_url, credential_data)
        jwt_credential = json.loads(response.read())
        return jwt_credential

def _save_groups_for_consumer(kong_admin_api_url, consumer):
    username = consumer["username"]
    input_groups = consumer["groups"]
    consumer_acls_url = kong_admin_api_url + "/consumers/" + username + "/acls"
    saved_acls_details = json.loads(urllib2.urlopen(consumer_acls_url).read())
    saved_acls = saved_acls_details["data"]
    saved_groups = [acl["group"] for acl in saved_acls]
    input_groups_to_be_created = [input_group for input_group in input_groups if input_group not in saved_groups]
    saved_groups_to_be_deleted = [saved_group for saved_group in saved_groups if saved_group not in input_groups]

    for input_group in input_groups_to_be_created:
        print("Adding group {} for consumer {}".format(input_group, username));
        json_request("POST", consumer_acls_url, {'group': input_group})

    for saved_group in saved_groups_to_be_deleted:
        print("Deleting group {} for consumer {}".format(saved_group, username));
        json_request("DELETE", consumer_acls_url + "/" + saved_group, "")

def _save_credentials_to_a_file(credential, file):
    with open(file, 'rb+') as f:
        f.truncate()
        f.write("key: {} \n".format(credential['key']))
        f.write("secret: {} \n".format(credential['secret']))


if  __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Configure kong consumers')
    parser.add_argument('consumers_file_path', help='Path of the json file containing consumer data')
    parser.add_argument('--kong-admin-api-url', help='Admin url for kong', default='http://localhost:8001')
    parser.add_argument('--kong-credentials-file-path', help='Filename to save kong credentials', default='/tmp/kong_credentials.txt')
    args = parser.parse_args()
    with open(args.consumers_file_path) as consumers_file:
        input_consumers = json.load(consumers_file)
        try:
            save_consumers(args.kong_admin_api_url, input_consumers, args.kong_credentials_file_path)
        except urllib2.HTTPError as e:
            error_message = e.read()
            print(error_message)
            raise
