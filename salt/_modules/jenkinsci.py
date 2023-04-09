'''
The jenkinsci module supplies Jenkins CI API management and functionality.
'''
# Import Python libs
import base64
import json
import logging
import ssl

# py2/py3 compatibility
try:
    from cookielib import CookieJar
    import urllib
    import urllib2

except ImportError:
    from http.cookiejar import CookieJar
    from urllib import request as urllib2
    from urllib import parse as urllib

# Import Salt libs
import salt.exceptions

log = logging.getLogger(__name__)

__virtualname__ = 'jenkinsci'


class JenkinsInterface(object):
    def _open_connection(self, url, headers={}, method='GET', data=None):
        request = urllib2.Request(url, headers=headers, data=data)
        request.get_method = lambda: method
        return self.__opener.open(request)

    def __init__(self, endpoint=None, username=None):
        '''
        Authenticate with the endpoint, get us some cookies.
        '''
        ctx = ssl.create_default_context()
        ctx.check_hostname = True
        ctx.verify_mode = ssl.CERT_REQUIRED
        ctx.set_ciphers('HIGH')
        self.__https_handler = urllib2.HTTPSHandler(context=ctx)

        # Determine endpoint.
        dom = __pillar__['consul']['site']['domain']
        self.__endpoint = 'https://jenkins.service.{}:8080/jenkins'.format(dom)

        # Determine user.
        if username is None:
            if 'salt' not in __pillar__.get('jenkins', {}).get('users') is None:
                message = 'Cannot determine Jenkins user to authenticate with'
                raise salt.exceptions.ArgumentValueError(message)

            username = 'salt'

        # Fetch password from the pillar.
        user_data = __pillar__.get('jenkins', {}).get('users').get(username)

        if not isinstance(user_data, dict) or user_data.get('password') is None:
            message = 'Cannot determine password for jenkins user "{0}"'
            raise salt.exceptions.ArgumentValueError(message.format(username))

        password = user_data['password']

        # Build headers for request.
        b64string = '{0}:{1}'.format(username, password).encode('utf-8')
        self.__auth = base64.b64encode(b64string)

        # Build opener and cookiejar.
        cookie_handler = urllib2.HTTPCookieProcessor(CookieJar())
        self.__opener = urllib2.build_opener(self.__https_handler,
                                             cookie_handler)


    def __call(self, uri, headers={}, method='GET', data=None):
        '''
        Invoke method using endpoint, unserialize and return the response.
        '''
        try:
            connection = self._open_connection(self.__endpoint + uri,
                                               headers=headers, method=method,
                                               data=data)

            raw_response = connection.read().decode('utf-8')
            headers = dict(connection.getheaders())

            if headers.get('Content-Type', '').startswith('application/json'):
                return json.loads(raw_response)

            return raw_response

        except (urllib2.HTTPError, urllib2.URLError) as err:
            raise salt.exceptions.CommandExecutionError(err.reason)

        except (TypeError, ValueError):
            message = 'Received a malformed response: {0}'.format(raw_response)
            raise salt.exceptions.CommandExecutionError(message)

    def __get_crumb(self, path):
        '''
        Get a Jenkins Crumb valid for the given path.
        '''
        headers = {
            'Accept': 'application/json',
            'Authorization': 'Basic {0}'.format(self.__auth.decode('utf-8')),
            'Content-Type': 'application/x-www-form-urlencoded'
        }

        response = self.__call('/crumbIssuer/api/json', headers)

        if 'crumb' not in response or 'crumbRequestField' not in response:
            message = 'Crumb missing in response: {0}'.format(response)
            raise salt.exceptions.CommandExecutionError(message)

        return response['crumbRequestField'], response['crumb']

    def call(self, path, headers={}, method='GET', data=None):
        '''
        Get a crumb for the specified path and issue a request with it.
        '''
        headers.update([
            ('Authorization', 'Basic {0}'.format(self.__auth.decode('utf-8'))),
            self.__get_crumb(path)
        ])

        if 'Accept' not in headers:
            headers['Accept'] = 'application/json'

        return self.__call(path, headers, method, data)


def create_job(job, file_path):
    '''
    Creates a job with the specified name using the XML document specified
    by file_path.
    '''
    headers = {
        'Accept': 'application/xml',
        'Content-Type': 'application/xml'
    }

    with open(file_path, 'r') as f:
        xml = f.read()

    return JenkinsInterface().call('/createItem?name={0}'.format(job),
                                   headers=headers, method='POST',
                                   data=xml.encode('utf-8'))


def get_job(job):
    '''
    Returns information about the specified job.
    '''
    return JenkinsInterface().call('/job/{0}/api/json'.format(job))


def get_job_xml(job, file_path=None):
    '''
    Returns the configuration for the specified job.

    If file_path is specified, the XML document is saved to the local
    filesystem at the specified path.
    '''
    headers = {
        'Accept': 'application/xml'
    }

    xml = JenkinsInterface().call('/job/{0}/config.xml'.format(job),
                                  headers=headers)

    if file_path is not None:
        with open(file_path, 'w') as f:
            f.write(xml)

    return xml


def list_jobs():
    '''
    Lists the configured jobs in the Jenkins CI instance.
    '''
    jobs = JenkinsInterface().call('/api/json')['jobs']
    return [job['name'] for job in jobs]


def toggle_node_offline(node, reason=None, **kwarg):
    '''
    Marks the specified worker offline/offline.
    '''
    url = '/computer/{0}/toggleOffline'.format(node)

    if reason is not None:
        url += '?{0}'.format(urllib.urlencode({'offlineMessage': reason}))

    JenkinsInterface().call(url, method='POST')
