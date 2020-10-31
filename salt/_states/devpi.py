'''
The devpi module supplies devpi management and functionality.
'''
# Import Python libs
import logging

# Import Salt libs
import salt.exceptions

log = logging.getLogger(__name__)

__virtualname__ = 'devpi'


def __virtual__():
    if 'devpi.get_users_and_indexes' in __salt__:
        return True

    return False


def index_absent(name, username, endpoint=None, user=None):
    '''
    Deletes the index owned by the given user with the specified name
    if it exists.
    '''
    ret = {
        'name': name,
        'result': True,
        'changes': {},
    }

    try:
        details = __salt__['devpi.get_index'](username, name,
                                              endpoint=endpoint, user=user)

    except salt.exceptions.CommandExecutionError as error:
        if str(error).lower().strip() == 'not found':
            ret['comment'] = 'No index named "{0}/{1}" currently exists'
            ret['comment'] = ret['comment'].format(username, name)
            return ret

        raise error

    if __opts__['test'] is True:
        ret['result'] = None
        ret['changes'] = {'old': details, 'new': {}}
        ret['comment'] = 'The index "{0}/{1}" will be deleted'
        ret['comment'] = ret['comment'].format(username, name)
        return ret

    __salt__['devpi.delete_index'](username, name, endpoint=endpoint, user=user)

    ret['result'] = True
    ret['changes'] = {'old': details, 'new': {}}
    ret['comment'] = 'The index "{0}/{1}" was deleted'
    ret['comment'] = ret['comment'].format(username, name)
    return ret


def user_absent(name, endpoint=None, user=None):
    '''
    Deletes the user with the specified name if it exists.
    '''
    ret = {
        'name': name,
        'result': True,
        'changes': {},
    }

    try:
        details = __salt__['devpi.get_user'](name, endpoint=endpoint, user=user)

    except salt.exceptions.CommandExecutionError as error:
        if str(error).lower().strip() == 'not found':
            ret['comment'] = 'No user named "{0}" currently exists'.format(name)
            return ret

        raise error

    if __opts__['test'] is True:
        ret['result'] = None
        ret['changes'] = {'old': details, 'new': {}}
        ret['comment'] = 'The user "{0}" will be deleted'.format(name)
        return ret

    __salt__['devpi.delete_user'](name, endpoint=endpoint, user=user)

    ret['result'] = True
    ret['changes'] = {'old': details, 'new': {}}
    ret['comment'] = 'The user "{0}" was deleted'.format(name)
    return ret


def index_present(name, username, bases=[], volatile=True, endpoint=None,
                  user=None):
    '''
    Ensures the index exists with the specified properties.
    '''
    ret = {
        'name': name,
        'result': True,
        'changes': {},
    }

    details = {}
    user_details = {}

    want = {
        'bases': bases,
        'volatile': volatile,
    }

    # Get the current index to see if the index already exists.
    try:
        user_details = __salt__['devpi.get_user'](username,
                                                  endpoint=endpoint, user=user)

        details = __salt__['devpi.get_index'](username, name,
                                              endpoint=endpoint, user=user)

    except salt.exceptions.CommandExecutionError as error:
        if str(error).lower().strip() != 'not found':
            raise error

    # Determine if changes are necessary.
    trimmed_details = {
        'bases': details.get('bases', []),
        'volatile': details.get('volatile', True),
    }

    update = trimmed_details != want or details == {}

    if __opts__['test'] is True and update:
        ret['result'] = None
        ret['changes'] = {'old': details, 'new': want}

        if name in user_details.get('indexes', {}):
            ret['comment'] = 'The index "{0}/{1}" does not meet expectations'

        else:
            ret['comment'] = 'The index "{0}/{1}" would be created'

        ret['comment'] = ret['comment'].format(username, name)
        return ret

    if not update:
        ret['comment'] = 'The index "{0}/{1}" already exists as specified'
        ret['comment'] = ret['comment'].format(username, name)
        return ret

    # Create or modify the user as needed.
    __salt__['devpi.create_index'](username, name, bases=bases,
                                   volatile=volatile, endpoint=endpoint,
                                   user=user)

    ret['result'] = True
    ret['changes'] = {'old': details, 'new': want}
    ret['comment'] = 'The index "{0}/{1}" was created'.format(username, name)
    return ret


def user_present(name, password, email=None, force_update=False,
                 endpoint=None, user=None):
    '''
    Ensures the user exists with the specified properties.

    force_update can optionally be used to force an commit to devpi if
    nothing other than the password appears dissimilar.
    '''
    ret = {
        'name': name,
        'result': True,
        'changes': {},
    }

    details = {}
    want = {
        'username': name,
        'indexes': {},
    }

    if email is not None:
        want['email'] = email

    # Get the current user to see if the user already exists.
    try:
        details = __salt__['devpi.get_user'](name, endpoint=endpoint, user=user)

    except salt.exceptions.CommandExecutionError as error:
        if str(error).lower().strip() != 'not found':
            raise error

    # Determine if changes are necessary.
    update = force_update or details == {}

    if want.get('email') != details.get('email') and email is not None:
        update = True

    if __opts__['test'] is True and update:
        action = 'modified' if details != {} else 'created'

        ret['result'] = None
        ret['changes'] = {'old': details, 'new': want}
        ret['comment'] = 'The user "{0}" will be {1}'.format(name, action)
        return ret

    if not update:
        ret['comment'] = 'The user "{0}" already exists as specified'
        ret['comment'] = ret['comment'].format(name)
        return ret

    # Create or modify the user as needed.
    if details == {}:
        __salt__['devpi.create_user'](name, password, email=email,
                                      endpoint=endpoint, user=user)

    else:
        __salt__['devpi.modify_user'](name, password, email=email,
                                      endpoint=endpoint, user=user)

    ret['result'] = True
    ret['changes'] = {'old': details, 'new': want}
    ret['comment'] = 'The user "{0}" was updated'.format(name)
    return ret
