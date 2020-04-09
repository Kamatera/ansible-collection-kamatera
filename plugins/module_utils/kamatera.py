# Copyright: (c) 2020, Ori Hoch
# MIT License

from __future__ import absolute_import, division, print_function
__metaclass__ = type

from ansible.module_utils.urls import open_url, urllib_error


def request(module, path, method='GET', request_data=None):
    url = module.params['api_url'].strip('/') + '/' + path.strip('/')
    if request_data:
        request_data = module.jsonify(request_data)
    headers = dict(
        AuthClientId=module.params['api_client_id'],
        AuthSecret=module.params['api_secret'],
        Accept='application/json'
    )
    headers['Content-Type'] = 'application/json'
    try:
        http_response = open_url(url, request_data, headers, method, timeout=module.params['wait_timeout_seconds'])
        if hasattr(http_response, 'status'):
            is_error = http_response.status != 200
        else:
            is_error = http_response.getcode() != 200
    except urllib_error.HTTPError as err:
        http_response = err
        is_error = True
    res_text = None
    try:
        res_text = http_response.read()
        data = module.from_json(res_text)
    except Exception as e:
        data = {'message': 'invalid response (' + str(e) + ')'}
        is_error = True
    if is_error:
        if 'message' in data:
            error_msg = data['message']
        elif res_text:
            error_msg = res_text
        else:
            error_msg = 'unexpected error'
        module.fail_json(msg=error_msg)
    else:
        return data
