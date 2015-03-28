## gesture_recorder

## setup

first ```npm install``` the webapp requirements, then ```grunt``` to build the webapp. for dev, you can ```grunt-watch``` to re-build the webapp on filechange.

now ```python gesture_recorder.py``` to run the flask server.

## details 

the flask server launches ```mindwave_client.py```, which communicates with the mindwave device and POSTs packets to the local server

the local server also serves a webpage front-end