import requests

def handler(context, inputs):
    """Set a name for a machine

    :param inputs
    :param inputs.resourceNames: Contains the original name of the machine.
           It is supplied from the event data during actual provisioning
           or from user input for testing purposes.
    :param inputs.newName: The new machine name to be set.
    :return The desired machine name.
    """
    
    search = inputs['customProperties']['nameSearch']
    
    url = f'https://swapi.co/api/people/?search={search}'
    
    r = requests.get(url)
    
    print(r.json())
    
    eye_color = r.json()['results'][0]['eye_color']
    birth_year = r.json()['results'][0]['birth_year']
    
    new_name = eye_color+birth_year
    
    old_name = inputs["resourceNames"][0]

    outputs = {}
    outputs["resourceNames"] = inputs["resourceNames"]
    outputs["resourceNames"][0] = new_name

    print("Setting machine name from {0} to {1}".format(old_name, new_name))

    return outputs
