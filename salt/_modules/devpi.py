'''
The devpi module supplies devpi management and functionality.
'''
# Import Python libs
import base64
import json
import logging
import ssl

# py2/py3 compatibility
try:
    import urllib
    import urllib2

except ImportError:
    from urllib import request as urllib2
    from urllib import parse as urllib

# Import Salt libs
import salt.exceptions

log = logging.getLogger(__name__)

__virtualname__ = 'devpi'


def __virtual__():
    return __virtualname__


def _api_request(uri, headers={}, method='GET', data=None, user=None):
    '''
    Makes an devpi API request to the specified URI with the specified HTTP
    method returns the resulting document.  Headers will always include
    "Accept: application/json" if data is supplied unless explicitly overriden.

    The user is assumed to be pillar['devpi']['user'] if it is not supplied.
    The password for the user will always be looked up and fetched via
    pillar['devpi']['users']['password'] unconditionally to prevent leakage.
    '''
    # Determine user.
    if user is None:
        if 'root' not in __pillar__.get('devpi', {}).get('users') is None:
            message = 'Cannot determine devpi user to authenticate with'
            raise salt.exceptions.ArgumentValueError(message)

        user = 'root'

    # Fetch password from the pillar.
    user_data = __pillar__.get('devpi', {}).get('users').get(user)

    if not isinstance(user_data, dict) or user_data.get('password') is None:
        message = 'Cannot determine password for devpi user "{0}"'
        raise salt.exceptions.ArgumentValueError(message.format(user))

    password = user_data['password']

    # Build headers for request.
    auth = base64.b64encode('{0}:{1}'.format(user, password).encode('utf-8'))

    use_headers = {
        'Accept': 'application/json',
        'Authorization': 'Basic {0}'.format(auth.decode('utf-8')),
    }

    if data is not None:
        use_headers['Content-Type'] = 'application/json'
        data = json.dumps(data).encode('utf-8')

    use_headers.update(headers)

    # Setup the connection opener for HTTP/HTTPS as needed.
    if uri.startswith('https'):
        ctx = ssl.create_default_context()
        ctx.check_hostname = True
        ctx.verify_mode = ssl.CERT_REQUIRED
        ctx.set_ciphers('HIGH')

        opener = urllib2.build_opener(urllib2.HTTPSHandler(context=ctx))

    else:
        opener = urllib2.build_opener(urllib2.HTTPHandler())

    # Make the request.
    try:
        request = urllib2.Request(uri, headers=use_headers, data=data)
        request.get_method = lambda: method
        response = opener.open(request).read().decode('utf-8')

        if use_headers.get('Accept', '') == 'application/json':
            response = json.loads(response)

        return response

    except (urllib2.HTTPError, urllib2.URLError) as err:
        raise salt.exceptions.CommandExecutionError(err.reason)

    except (TypeError, ValueError):
        raise Exception(str(response))
        message = 'The devpi API returned an incorrectly formatted response.'
        raise salt.exceptions.CommandExecutionError(message)


def _default_transport():
    """
    Returns 'https' if SSL fullchain and private key are present; else 'http'.
    """
    ssl_fullchain_filepath = '/etc/ssl/certs/{0}-fullchain.pem'.format(__grains__['id'])
    ssl_key_filepath = '/etc/ssl/private/{0}-privkey.pem'.format(__grains__['id'])

    ssl_keychain_exists = __salt__['file.file_exists'](ssl_fullchain_filepath)
    ssl_key_exists = __salt__['file.file_exists'](ssl_fullchain_filepath)
    return 'https' if ssl_keychain_exists and ssl_key_exists else 'http'


def create_index(username, index, bases=[], volatile=True, endpoint=None,
                 user=None):
    """
    Creates an index for the given user with the specified properties.
    """
    if endpoint is None:
        endpoint = '{0}://{1}'.format(_default_transport(), __grains__['fqdn'])

    data = {
        'bases': bases,
        'volatile': volatile,
    }

    if not endpoint.endswith('/'):
        uri = '{0}/{1}/{2}'.format(endpoint, username, index)
    else:
        uri = '{0}{1}/{2}'.format(endpoint, username, index)

    return _api_request(uri, user=user, method='PUT', data=data)['result']


def create_user(username, password, endpoint=None, email=None, user=None):
    """
    Creates the specified user with the given username/password/e-mail.
    """
    if endpoint is None:
        endpoint = '{0}://{1}'.format(_default_transport(), __grains__['fqdn'])

    account = {'password': password}

    if email is not None:
        account['email'] = email

    if not endpoint.endswith('/'):
        uri = '{0}/{1}'.format(endpoint, username)
    else:
        uri = '{0}{1}'.format(endpoint, username)

    return _api_request(uri, method='PUT', data=account, user=user)['result']


def delete_index(username, index, endpoint=None, user=None):
    """
    Deletes the specified index.
    """
    if endpoint is None:
        endpoint = '{0}://{1}'.format(_default_transport(), __grains__['fqdn'])

    if not endpoint.endswith('/'):
        uri = '{0}/{1}/{2}'.format(endpoint, username, index)
    else:
        uri = '{0}{1}/{2}'.format(endpoint, username, index)

    return _api_request(uri, method='DELETE', user=user)['message']


def delete_user(username, endpoint=None, user=None):
    """
    Deletes the specified user.
    """
    if endpoint is None:
        endpoint = '{0}://{1}'.format(_default_transport(), __grains__['fqdn'])

    if username == 'root':
        message = 'Refusing to delete the "root" user'
        raise salt.exceptions.CommandExecutionError(message)

    if not endpoint.endswith('/'):
        uri = '{0}/{1}'.format(endpoint, username)
    else:
        uri = '{0}{1}'.format(endpoint, username)

    return _api_request(uri, method='DELETE', user=user)['message']


def get_index(username, index, endpoint=None, user=None):
    """
    Returns index information for a specific user.
    """
    if endpoint is None:
        endpoint = '{0}://{1}'.format(_default_transport(), __grains__['fqdn'])

    if not endpoint.endswith('/'):
        uri = '{0}/{1}/{2}'.format(endpoint, username, index)
    else:
        uri = '{0}{1}/{2}'.format(endpoint, username, index)

    return _api_request(uri, user=user)['result']


def get_user(username, endpoint=None, user=None):
    """
    Returns information and indexes for a specific user.
    """
    if endpoint is None:
        endpoint = '{0}://{1}'.format(_default_transport(), __grains__['fqdn'])

    if not endpoint.endswith('/'):
        uri = '{0}/{1}'.format(endpoint, username)
    else:
        uri = '{0}{1}'.format(endpoint, username)

    return _api_request(uri, user=user)['result']


def get_users_and_indexes(endpoint=None, user=None):
    """
    Returns a map of all users and indexes.
    """
    if endpoint is None:
        endpoint = '{0}://{1}'.format(_default_transport(), __grains__['fqdn'])

    if not endpoint.endswith('/'):
        endpoint = endpoint + '/'

    return _api_request(endpoint, user=user)['result']


def modify_user(username, password, endpoint=None, email=None, user=None):
    """
    Changes the specified by setting the given username/password/e-mail.
    """
    if endpoint is None:
        endpoint = '{0}://{1}'.format(_default_transport(), __grains__['fqdn'])

    account = {'password': password}

    if email is not None:
        account['email'] = email

    if not endpoint.endswith('/'):
        uri = '{0}/{1}'.format(endpoint, username)
    else:
        uri = '{0}{1}'.format(endpoint, username)

    return _api_request(uri, method='PATCH', data=account, user=user)['result']
