'''
The hover module supplies Hover DNS management and functionality.
'''
# Import Python libs
import json
import logging
import ssl

# py2/py3 compatibility
try:
    from cookielib import Cookie, CookieJar
    import urllib
    import urllib2

except ImportError:
    from http.cookiejar import Cookie, CookieJar
    from urllib import request as urllib2
    from urllib import parse as urllib

# Import Salt libs
import salt.exceptions

log = logging.getLogger(__name__)

__virtualname__ = 'hover'


class HoverException(Exception):
    pass


class HoverInterface(object):
    def _open_connection(self, url, headers={}, method='GET', data=None):
        request = urllib2.Request(url, headers=headers, data=data)
        request.get_method = lambda: method
        return self.__opener.open(request)

    def __init__(self, user_id, session_token, auth_token):
        '''
        Authenticate with the endpoint, get us some cookies.
        '''
        # Hover's API does not have strong DH right now; odd?
        ctx = ssl.create_default_context()
        ctx.check_hostname = True
        ctx.verify_mode = ssl.CERT_REQUIRED
        ctx.set_ciphers('HIGH:!DH:!aNULL')
        https_handler = urllib2.HTTPSHandler(context=ctx)

        self.__endpoint = 'https://www.hover.com/api'

        # Hover's API now requires MFA logins (it did not formerly).
        # You must acquire a user ID, session token, and auth token from
        # browser after completing a MFA login. Those are then used here.
        cookie_jar = CookieJar()
        cookie_handler = urllib2.HTTPCookieProcessor(cookie_jar)
        self.__opener = urllib2.build_opener(https_handler, cookie_handler)

        # The user ID cookie actually has an expiration date, but somehow
        # getting that value into here is a future exercise.
        common_cookie_params = {
            'version': 0,
            'port': None,
            'port_specified': False,
            'domain_specified': True,
            'path': '/',
            'path_specified': True,
            'secure': False,
            'expires': None,
            'discard': False,
            'comment_url': None,
        }

        user_id_c = Cookie(name='__zlcmid', value=user_id, domain=".hover.com",
                           domain_initial_dot=True, comment="Hover User ID",
                           rest={"HostOnly": False, "HttpOnly": False},
                           **common_cookie_params)

        session_c = Cookie(name='hover_session', value=session_token,
                           domain="www.hover.com", domain_initial_dot=False,
                           comment="Hover Session Token",
                           rest={"HostOnly": True, "HttpOnly": True},
                           **common_cookie_params)

        auth_c = Cookie(name='hoverauth', value=auth_token,
                        domain="www.hover.com", domain_initial_dot=False,
                        comment="Hover Authentication Token",
                        rest={"HostOnly": True, "HttpOnly": False},
                        **common_cookie_params)

        cookie_jar.set_cookie(user_id_c)
        cookie_jar.set_cookie(session_c)
        cookie_jar.set_cookie(auth_c)

    def call(self, uri, headers={}, method='GET', data=None):
        '''
        Invoke method using endpoint, unserialize and return the response.
        '''
        try:
            connection = self._open_connection(self.__endpoint + uri,
                                               headers=headers, method=method,
                                               data=data)

            raw_response = connection.read().decode('ascii')
            response = json.loads(raw_response)

            if 'succeeded' not in response or not response['succeeded']:
                raise HoverException('Endpoint signaled a failure')

            return response

        except (urllib2.HTTPError, urllib2.URLError) as err:
            raise HoverException(err.reason)

        except (TypeError, ValueError):
            message = 'Received a malformed response: {0}'
            raise HoverException(message.format(raw_response))


def __virtual__():
    return __virtualname__


def get_records(domain, hover=None):
    '''
    Returns information and records about a particular domain.
    '''
    if hover is None:
        credentials = __pillar__['hover'][domain]
        hover = HoverInterface(credentials['user_id'],
                               credentials['session_token'],
                               credentials['auth_token'])

    domains = hover.call('/dns', method='GET').get('domains', [])
    filtered = [x for x in domains if x['domain_name'] == domain]

    if len(filtered) != 1:
        message = 'Hover API returned bad data for domain: {0}'
        raise salt.exceptions.CommandExecutionError(message.format(domain))

    return filtered[0]


def put_a_aaaa_records(domain, ip_address, record_type, hostname=''):
    '''
    Updates the A record(s) with the specified IP address.
    '''
    credentials = __pillar__['hover'][domain]
    hover = HoverInterface(credentials['user_id'],
                           credentials['session_token'],
                           credentials['auth_token'])
    entries = get_records(domain, hover=hover).get('entries', [])

    record_type = record_type.lower().strip()
    records = [x for x in entries
               if x['type'].lower().strip() == record_type
               and (x['name'] == hostname if hostname != '' else True)]

    if len(records) == 0:
        message = 'Could not find matching {0} record(s) for domain: {1}'
        message = message.format(record_type.upper(), domain)
        raise salt.exceptions.CommandExecutionError(message)

    for record in records:
        if record['content'].lower().strip() != ip_address:
            uri = '/dns/{0}'.format(record['id'])
            data = urllib.urlencode({'content': ip_address}).encode()
            hover.call(uri, method='PUT', data=data)
            record['content'] = ip_address

    return records


def put_acme_challenge(domain, challenge, host=None):
    '''
    Updates the _acme-challenge TXT record with the specified challenge string.
    '''
    credentials = __pillar__['hover'][domain]
    hover = HoverInterface(credentials['user_id'],
                           credentials['session_token'],
                           credentials['auth_token'])
    entries = get_records(domain, hover=hover).get('entries', [])

    record = '_acme-challenge'

    if host not in ['', None, '*']:
        record = '_acme-challenge.{0}'.format(host)

    acme_entries = [x for x in entries if x['type'].lower().strip() == 'txt'
                    and x['name'].lower().strip() == record]

    if len(acme_entries) != 1:
        if host not in ['', None, '*']:
            message = 'Could not find _acme-challenge TXT record for: {0}'
            raise salt.exceptions.CommandExecutionError(message.format(domain))

        record = acme_entries[0 if host != '*' else -1]

    else:
        record = acme_entries[0]

    uri = '/dns/{0}'.format(record['id'])
    data = urllib.urlencode({'content': challenge}).encode()
    hover.call(uri, method='PUT', data=data)

    record['content'] = challenge
    return record
