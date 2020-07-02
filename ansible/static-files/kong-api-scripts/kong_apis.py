import urllib2, argparse, json

from common import get_apis, json_request, get_api_plugins

def save_apis(kong_admin_api_url, input_apis):
    apis_url = "{}/apis".format(kong_admin_api_url)
    saved_apis = get_apis(kong_admin_api_url)

    print("Number of input APIs : {}".format(len(input_apis)))
    print("Number of existing APIs : {}".format(len(saved_apis)))

    input_api_names = [api["name"] for api in input_apis]
    saved_api_names = [api["name"] for api in saved_apis]

    print("Input APIs : {}".format(input_api_names))
    print("Existing APIs : {}".format(saved_api_names))

    input_apis_to_be_created = [input_api for input_api in input_apis if input_api["name"] not in saved_api_names]
    input_apis_to_be_updated = [input_api for input_api in input_apis if input_api["name"] in saved_api_names]
    saved_api_to_be_deleted = [saved_api for saved_api in saved_apis if saved_api["name"] not in input_api_names]

    for input_api in input_apis_to_be_created:
        print("Adding API {}".format(input_api["name"]))
        json_request("POST", apis_url, _sanitized_api_data(input_api))

    for input_api in input_apis_to_be_updated:
        print("Updating API {}".format(input_api["name"]))
        saved_api_id = [saved_api["id"] for saved_api in saved_apis if saved_api["name"] == input_api["name"]][0]
        input_api["id"] = saved_api_id
        json_request("PATCH", apis_url + "/" + saved_api_id, _sanitized_api_data(input_api))

    for saved_api in saved_api_to_be_deleted:
        print("Deleting API {}".format(saved_api["name"]));
        json_request("DELETE", apis_url + "/" + saved_api["id"], "")

    for input_api in input_apis:
        _save_plugins_for_api(kong_admin_api_url, input_api)

def _save_plugins_for_api(kong_admin_api_url, input_api_details):
    get_plugins_max_page_size = 2000
    api_name = input_api_details["name"]
    input_plugins = input_api_details["plugins"]
    api_pugins_url = "{}/apis/{}/plugins".format(kong_admin_api_url, api_name)
    saved_plugins_including_consumer_overrides = get_api_plugins(kong_admin_api_url, api_name)
    saved_plugins_without_consumer_overrides = [plugin for plugin in saved_plugins_including_consumer_overrides if not plugin.get('consumer_id')]

    saved_plugins = saved_plugins_without_consumer_overrides
    input_plugin_names = [input_plugin["name"] for input_plugin in input_plugins]
    saved_plugin_names = [saved_plugin["name"] for saved_plugin in saved_plugins]

    input_plugins_to_be_created = [input_plugin for input_plugin in input_plugins if input_plugin["name"] not in saved_plugin_names]
    input_plugins_to_be_updated = [input_plugin for input_plugin in input_plugins if input_plugin["name"] in saved_plugin_names]
    saved_plugins_to_be_deleted = [saved_plugin for saved_plugin in saved_plugins if saved_plugin["name"] not in input_plugin_names]

    for input_plugin in input_plugins_to_be_created:
        print("Adding plugin {} for API {}".format(input_plugin["name"], api_name));
        json_request("POST", api_pugins_url, input_plugin)

    for input_plugin in input_plugins_to_be_updated:
        print("Updating plugin {} for API {}".format(input_plugin["name"], api_name));
        saved_plugin_id = [saved_plugin["id"] for saved_plugin in saved_plugins if saved_plugin["name"] == input_plugin["name"]][0]
        input_plugin["id"] = saved_plugin_id
        json_request("PATCH", api_pugins_url + "/" + saved_plugin["id"], input_plugin)

    for saved_plugin in saved_plugins_to_be_deleted:
        print("Deleting plugin {} for API {}".format(saved_plugin["name"], api_name));
        json_request("DELETE", api_pugins_url + "/" + saved_plugin["id"], "")

def _sanitized_api_data(input_api):
    keys_to_ignore = ['plugins']
    sanitized_api_data = dict((key, input_api[key]) for key in input_api if key not in keys_to_ignore)
    return sanitized_api_data

if  __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Configure kong apis')
    parser.add_argument('apis_file_path', help='Path of the json file containing apis data')
    parser.add_argument('--kong-admin-api-url', help='Admin url for kong', default='http://localhost:8001')
    args = parser.parse_args()
    with open(args.apis_file_path) as apis_file:
        input_apis = json.load(apis_file)
        try:
            save_apis(args.kong_admin_api_url, input_apis)
        except urllib2.HTTPError as e:
            error_message = e.read()
            print(error_message)
            raise