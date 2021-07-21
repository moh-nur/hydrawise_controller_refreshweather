import requests
import time
import os

payload = {'grant_type': 'password', 'client_id': 'hydrawise_app', 'client_secret': os.environ['HYDRAWISE_CLIENT_SECRET'],
           'username': os.environ['HYDRAWISE_USERNAME'], 'password': os.environ['HYDRAWISE_PASSWORD'], 'scope': 'all'}
url = 'https://app.hydrawise.com/api/v2/oauth/access-token'

with requests.Session() as s:
    p = s.post(url, data=payload)
    rJson = p.json()
    time.sleep(1)

    headers = {'authorization': rJson['access_token']}
    payload = payload = "[{\"operationName\":\"removeWeatherStation\",\"variables\":{\"controllerId\":%d,\"weatherStationId\":%d},\"query\":\"mutation removeWeatherStation($controllerId: Int!, $weatherStationId: Int!) {\\n  removeWeatherStation(controllerId: $controllerId, weatherStationId: $weatherStationId)\\n}\\n\"}]" % (
        int(os.environ['HYDRAWISE_CONTROLLERID']), int(os.environ['HYDRAWISE_WEATHERSTATIONID']))
    url = 'https://app.hydrawise.com/api/v2/graph'
    r = s.post(url, data=payload, headers=headers)
    print(r.text)
    time.sleep(1)

    payload = "[{\"operationName\":\"addWeatherStation\",\"variables\":{\"controllerId\":%d,\"weatherStationId\":%d},\"query\":\"mutation addWeatherStation($controllerId: Int!, $weatherStationId: Int!) {\\n  addWeatherStation(controllerId: $controllerId, weatherStationId: $weatherStationId)\\n}\\n\"}]" % (
        int(os.environ['HYDRAWISE_CONTROLLERID']), int(os.environ['HYDRAWISE_WEATHERSTATIONID']))
    r = s.post(url, data=payload, headers=headers)
    print(r.text)
