import requests
import time
import os

HYDRAWISE_CLIENT_SECRET = os.environ['HYDRAWISE_CLIENT_SECRET']
HYDRAWISE_USERNAME = os.environ['HYDRAWISE_USERNAME']
HYDRAWISE_PASSWORD = os.environ['HYDRAWISE_PASSWORD']
HYDRAWISE_CONTROLLERID = os.environ['HYDRAWISE_CONTROLLERID']
HYDRAWISE_WEATHERSTATIONID = os.environ['HYDRAWISE_WEATHERSTATIONID']

def lambda_handler(event, context):
    payload = {'grant_type': 'password', 'client_id': 'hydrawise_app', 'client_secret': HYDRAWISE_CLIENT_SECRET,
               'username': HYDRAWISE_USERNAME, 'password': HYDRAWISE_PASSWORD, 'scope': 'all'}
    url = 'https://app.hydrawise.com/api/v2/oauth/access-token'

    with requests.Session() as s:
        p = s.post(url, data=payload)
        rJson = p.json()
        time.sleep(1)

        headers = {'authorization': rJson['access_token']}
        payload = "[{\"operationName\":\"removeWeatherStation\",\"variables\":{\"controllerId\":%d,\"weatherStationId\":%d},\"query\":\"mutation removeWeatherStation($controllerId: Int!, $weatherStationId: Int!) {\\n  removeWeatherStation(controllerId: $controllerId, weatherStationId: $weatherStationId)\\n}\\n\"}]" % (
            int(HYDRAWISE_CONTROLLERID), int(HYDRAWISE_WEATHERSTATIONID))
        url = 'https://app.hydrawise.com/api/v2/graph'
        r = s.post(url, data=payload, headers=headers)
        print(r.text)
        time.sleep(1)

        payload = "[{\"operationName\":\"addWeatherStation\",\"variables\":{\"controllerId\":%d,\"weatherStationId\":%d},\"query\":\"mutation addWeatherStation($controllerId: Int!, $weatherStationId: Int!) {\\n  addWeatherStation(controllerId: $controllerId, weatherStationId: $weatherStationId)\\n}\\n\"}]" % (
            int(HYDRAWISE_CONTROLLERID), int(HYDRAWISE_WEATHERSTATIONID))
        r = s.post(url, data=payload, headers=headers)
        print(r.text)
