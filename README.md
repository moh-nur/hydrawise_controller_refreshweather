# hydrawise_controller_refreshweather
Python script to set and unset your weather station for the Hydrawise irrigation controller. 

This functionality is needed for free users so that the controller can retrieve updated observations which is no done automatically in the free tier.

### How to use
Set the below environment variables and run the script using crontab or a github action. If using a github action ensure you set the environments using githubs secrets.

You can retrieve the client_secret, controllerid and weatherstationid by removing and adding a weather station via the browser and observing the values in your browsers developer tab.

- HYDRAWISE_USERNAME
- HYDRAWISE_PASSWORD
- HYDRAWISE_CLIENT_SECRET
- HYDRAWISE_CONTROLLERID
- HYDRAWISE_WEATHERSTATIONID

