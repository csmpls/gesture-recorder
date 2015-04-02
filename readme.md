## gesture_recorder

## Installation

1. Download/clone this repository
2. `cd` into the directory and `pip install -r requirements.txt`
3. `python server/gesture_recorder.py` and navigate your browser to 127.0.0.1:5000
4. Put on your headset, turn it on, enter a username + electrode position, and press join!

## Developing

first ```npm install``` the webapp requirements, then ```grunt``` to build the webapp. for dev, you can ```grunt-watch``` to re-build the webapp on filechange.

## Details 

the flask server launches a ```mindwave_client.py``` thread, which communicates with the mindwave device and POSTs packets to the local server. 

the local server also serves a webpage front-end. the local server and the webpage communicate over websockets.

the webapp has an (implemented but as-of-yet unused) signal freshness property, and a signal quality property relating to the mindwave device readings.

## Todo
- signal quality / connection UI tooltip
- auto-reconnect to device on disconnect
- stop recording data when the web frontend closes.
