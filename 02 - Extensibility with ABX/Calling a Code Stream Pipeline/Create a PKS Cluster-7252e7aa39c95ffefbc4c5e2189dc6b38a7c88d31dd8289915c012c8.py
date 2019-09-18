import json

def handler(context, inputs):
    workers = inputs['workers']
    size = inputs['size']
    hostname = inputs['hostname']
    comment = inputs['comment']

    payload = {}
    
    payload['comments'] = comment
    
    input = {}
    
    input['size'] = size
    input['hostname'] = hostname
    input['workers'] = workers
    
    payload['input'] = input
    
    pl = json.dumps(payload)
    
    url = "/pipeline/api/pipelines/1d099d4a6cbb92755861e6d1a7a92/executions"
    
    r = context.request(url, 'POST', pl)
    
    data = {}
    if r['status'] == 200:
        data['status'] = r['status']
        data['message'] = "Pipeline execution is successful"
    else:
        data['message'] = "Pipelinie execution has failed"
        data['status'] = r['status']
    return data
