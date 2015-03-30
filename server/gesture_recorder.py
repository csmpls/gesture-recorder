from flask import Flask, request, send_file, render_template
from flask.ext.socketio import SocketIO, emit
import thread
import json
import mindwave_client

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(app)

# global variables related to mindwave's state
mindwave_has_initialized = False

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
@socketio.on('connected')
def test_message(message):
	emit('sup', {'data': 'hello!'})


'''
		utils
'''
# returns NULL if mwm hasnt gotten a good signal yet
# and JSON OBJECT OF THE DATA if it has
def handle_data(data):
	global mindwave_has_initialized
	data = request.get_json()
	if not mindwave_has_initialized: 
		mindwave_has_initialized = check_if_initialized(data)
		return None
	return data

# checks if the neurosky is initialized
# TODO: open browser up when ns is initialized
def check_if_initialized(data):
	if (data['attention_esense']) > 0:
		print 'ok! navigate to 127.0.0.1:5000'
		return True
	return False
	

'''
		run the server
		TODO this should be its own file
'''
if __name__ == "__main__":
	# start a client, give it the url at which data is sent
	mindwave_client = mindwave_client.Client('http://localhost:5000/')
	thread.start_new_thread(mindwave_client.run, ())
	socketio.run(app)
	# app.run(port=4228,debug=True)