from .keycloak_admin import KeycloakAdmin

class KeycloakAdminChild(KeycloakAdmin):

    def __init__(self, server_url, username, password, realm_name='master', client_id='admin-cli', verify=True):
        print "in child"
        KeycloakAdmin.__init__(self, server_url, username, password, realm_name, client_id, verify);

    def mymethod():
        print "called method"
