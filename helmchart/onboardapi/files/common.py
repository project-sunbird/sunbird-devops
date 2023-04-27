import urllib2, json, logging
from retry import retry

logging.basicConfig()

# Due to issue https://github.com/Mashape/kong/issues/1912
# We can't loop through all apis page by page
# Hence this work around which fetches apis with page size limited to max_page_size
# max_page_size ensures we don't bring down DB by fetching lot of rows
# If we reach a state we have more apis than max_page_size,
# Increase value of max_page_size judiciously
def get_apis(kong_admin_api_url):
    max_page_size = 2000
    apis_url_with_size_limit = "{}/apis?size={}".format(kong_admin_api_url, max_page_size)
    apis_response = json.loads(retrying_urlopen(apis_url_with_size_limit).read())
    total_apis = apis_response["total"]
    if(total_apis > max_page_size):
        raise Exception("There are {} apis existing in system which is more than max_page_size={}. Please increase max_page_size in ansible/kong_apis.py if this is expected".format(total_apis, max_page_size))
    else:
       return apis_response["data"]

def get_api_plugins(kong_admin_api_url, api_name):
    get_plugins_max_page_size = 2000
    api_pugins_url = "{}/apis/{}/plugins".format(kong_admin_api_url, api_name)
    get_api_plugins_url = "{}?size={}".format(api_pugins_url, get_plugins_max_page_size)
    saved_api_details = json.loads(retrying_urlopen(get_api_plugins_url).read())
    return saved_api_details["data"]


def json_request(method, url, data=None):
    request_body = json.dumps(data) if data is not None else None
    request = urllib2.Request(url, request_body)
    if data:
        request.add_header('Content-Type', 'application/json')
    request.get_method = lambda: method
    response = retrying_urlopen(request)
    return response

@retry(exceptions=urllib2.URLError, tries=5, delay=2, backoff=2)
def retrying_urlopen(*args, **kwargs):
    return urllib2.urlopen(*args, **kwargs)