'''
The consul module supplies consul management and functionality.
'''
# Import Python libs
import json
import logging
import socket
import ssl

# py2/py3 compatibility
try:
    import httplib
    import urllib2

except ImportError:
    import http.client as httplib
    from urllib import request as urllib2

# Import Salt libs
import salt.exceptions

log = logging.getLogger(__name__)

__virtualname__ = 'consul'


def __virtual__():
    return __virtualname__


class ConsulHTTPSConnection(httplib.HTTPSConnection):
    def __init__(self, consul_host, **kwargs):
        consul_site = __pillar__['consul']['site']
        consul_domain = consul_site['domain']

        is_consul_server = __grains__['fqdn'] in consul_site['server_fqdns']
        role = 'server' if is_consul_server else 'client'
        self.ca_certs = '/etc/consul/{0}-agent-ca.pem'.format(consul_domain)
        self.cert_file = '/etc/consul/{0}-{1}.pem'.format(role, consul_domain)
        self.key_file = '/etc/consul/{0}-{1}-key.pem'.format(role,
                                                             consul_domain)

        super(ConsulHTTPSConnection, self).__init__(consul_host, 8501,
                                                    key_file=self.key_file,
                                                    cert_file=self.cert_file,
                                                    timeout=kwargs['timeout'])

    def connect(self):
        sock = socket.create_connection((self.host, self.port), self.timeout)

        self.sock = ssl.wrap_socket(sock, 
            keyfile = self.key_file, 
            certfile = self.cert_file,
            ca_certs = self.ca_certs,
            ciphers = 'HIGH',
            cert_reqs = ssl.CERT_REQUIRED,
            ssl_version = ssl.PROTOCOL_TLSv1_2
        )


class ConsulHTTPSHandler(urllib2.HTTPSHandler):
    def __init__(self, consul_host):
        self.consul_host = consul_host
        super(ConsulHTTPSHandler, self).__init__()

    def https_open(self, req):
        # Rather than pass in a reference to a connection class, we pass in
        # a reference to a function which, for all intents and purposes,
        # will behave as a constructor.
        return self.do_open(self.get_connection, req)

    def get_connection(self, _, timeout=10):
        return ConsulHTTPSConnection(self.consul_host, timeout=timeout)


def _api_request(url, headers={}, method='GET', data=None):
    '''
    Makes an consul API request to the specified URI with the specified HTTP
    method returns the resulting document.  Headers will always include
    "Accept: application/json" if data is supplied unless explicitly overriden.

    The cacert, cert, and key are assumed to be the same as the defaults that
    Consul itself uses for the node.
    '''
    consul_domain = __pillar__['consul']['site']['domain']
    consul_host = 'consul.service.{0}'.format(consul_domain)
    endpoint = 'https://{0}'.format(consul_host)

    headers['Accept'] = 'application/json; charset=utf-8'
    headers['X-Consul-Token'] = __pillar__['consul']['token'].strip()

    if data is not None:
        headers['Content-Type'] = 'application/json; charset=utf-8'

        if not isinstance(data, bytes):
            data = json.dumps(data).encode('utf-8')

    request = urllib2.Request(endpoint + url, headers=headers, data=data)
    request.get_method = lambda: method

    consul_https_handler = ConsulHTTPSHandler(consul_host)
    connection = urllib2.build_opener(consul_https_handler).open(request)
    return json.loads(connection.read().decode('utf-8'))


def session_create(name):
    data = {"Name": name}
    return _api_request('/v1/session/create', method='PUT', data=data)


def session_delete(uuid):
    return _api_request('/v1/session/destroy/{0}'.format(uuid), method='PUT')


def session_list():
    return _api_request('/v1/session/list')
