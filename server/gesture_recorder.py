from flask import Flask, request, send_file, render_template
from flask.ext.socketio import SocketIO, emit
import json
import mindwave_client
import time

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
		data = handle_data(request.get_json())
		# send socket.io
		socketio.emit('data', data)
		return 'ok'

	return '404'


'''
		socket communication with browser
'''
@socketio.on('connect')
def test_message(message):
	print 'user wants to connect to the mindwave!', message
	# print 'connecting it...'
	stop_mw_client_thread()
	emit('server_says', {'msg':'i stopped your mindwave!'})
	create_and_start_mw_client_thread()
	emit('server_says', {'msg':'i started the thread that should connect your mindwave!!'})
	# emit('server_says', {'msg':'i started the thread that connects to your mindwave!'})

def stop_mw_client_thread():
	global mw_client_thread
	mw_client_thread.stop()
	time.sleep(3) # wait 3 seconds to make sure the thread is stopped

def create_and_start_mw_client_thread():
	global mw_client_thread
	mw_client_thread = mindwave_client.Client('http://localhost:5000/')
	mw_client_thread.start()

'''
		utils
'''
def handle_data(data):
	return data

'''
		run the server
		TODO this should be its own file
'''
if __name__ == "__main__":
	# start a client, give it the url at which data is sent
	# global mw_client_stop_event
	# mw_client_stop_event = threading.Event()
	# mw_client = mindwave_client.Client('http://localhost:5000/')
	# mw_client_thread.daemon = True
	# mw_client_thread = threading.Thread(target=mw_client.run, args=())
	create_and_start_mw_client_thread()
	# mw_client_thread = mindwave_client.Client('http://localhost:5000/')
	# mw_client_thread.start(
	# thread.start_new_thread(mindwave_client.run, ())
	socketio.run(app)
	# app.run(port=4228,debug=True)