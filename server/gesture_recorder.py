from lib.utils import save_reading, get_trial_path, decode_dict
from flask import Flask, request, send_file, render_template
from flask.ext.socketio import SocketIO, emit
import lib.mindwave_client as mindwave_client
import json
import time
import traceback

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(app)

''' 
		deliver the webapp to the browser
		handle POST data from mindwave_client
'''
@app.route('/', methods = ['GET', 'POST'])
def hello():

	# deliver the webapp to the browser
	if request.method == 'GET':
		return render_template('index.html')

	# receive data from mindwave_client
	if request.method == 'POST':
		data = handle_data(request.json)
		# send socket.io
		socketio.emit('data', data)
		return 'ok'

	return '404'


'''
		socket communication with browser
'''
@socketio.on('connect')
def connect_to_mwm(message):
	print 'user wants to connect to the mindwave!', message
	# print 'connecting it...'
	stop_mw_client_thread()
	emit('server_says', {'msg':'i stopped your mindwave!'})
	create_and_start_mw_client_thread()
	emit('server_says', {'msg':'i started the thread that should connect your mindwave!!'})
	# emit('server_says', {'msg':'i started the thread that connects to your mindwave!'})

@socketio.on('record')
def record_gesture(message):
	global recorder_gesture
	global is_recording
	global trial_path

	print 'user wants to record a gesture!', decode_dict(message)

	# set global variables to users
	recorder_gesture = message['gesture']
	trial_path = get_trial_path(message['userId'],  message['electrodePosition'], recorder_gesture)

	is_recording = True

	# inform the client that we're reocrding
	emit('start_record', {'msg': 'im starting the recording!'})

'''
		utils
'''
def handle_data(data):
	global is_recording
	if (is_recording): save_data(json.dumps(data))
	return data

def save_data(data):
	global framesRecorded
	global is_recording
	global numFrames
	global recorder_gesture
	global trial_path
	# if we've recorded all our frames, 
	if (framesRecorded == numFrames): 
		# reset the global vars
		framesRecorded = 0
		is_recording = False
		trial_path = None
		# and inform the client that we're done
		socketio.emit('end_record', {'msg': 'done recording'})
		return 0
	else:
		framesRecorded += 1
		save_reading(data, trial_path)
		return 0

def stop_mw_client_thread():
	global mw_client_thread
	if mw_client_thread is not None:
		mw_client_thread.stop()
		time.sleep(2) # wait 2 seconds to make sure the thread is stopped

def create_and_start_mw_client_thread():
	global mw_client_thread
	mw_client_thread = mindwave_client.Client('http://localhost:5000/')
	mw_client_thread.start()

'''
		run the server
'''
if __name__ == "__main__":

	# number of frames to record
	# 1 sec == 2 frames
	global numFrames
	numFrames = 20

	global mw_client_thread
	mw_client_thread = None

	global framesRecorded
	framesRecorded = 0

	global is_recording
	is_recording = False

	global recorder_id
	global recorder_electrode_pos
	global recorder_gesture

	socketio.run(app)
	# app.run(port=4228,debug=True)