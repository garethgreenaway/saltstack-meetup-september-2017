#!py
import hashlib
import hmac
def run():
    '''Verify the signature for a Github webhook and deploy the appropriate code'''
    _, signature = data['headers'].get('X-Hub-Signature').split('=')
    body = data['body']
    target = tag.split('/')[-1]
    key = __opts__.get('github', {}).get('webhook-key')
    computed_signature = hmac.new(key, body,hashlib.sha1).hexdigest()
    if computed_signature == signature:
        project = data['post']['repository']['name'].lower()
        if 'ref' in data['post']:
            branch = data['post']['ref'].split('/')[2]
        else:
            return {}
        kwargs = {'saltenv': 'saltmaster', 'pillar': {'project': project, 'branch': branch}}
        return {
            'github_webhook_update': {
                'local.state.sls': [ {'tgt': 'saltmaster'}, {'arg': ['salt-master-git-single']}, {'kwarg': kwargs}, ]
            }
        }
    else:
        return {}
