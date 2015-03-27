from flask import Flask, request
import thread
import json
import mindwave_client

app = Flask(__name__)

# global variables related to mindwave's state
mindwave_has_initialized = False

# @app.route('/')
# def hello():
# 	return 'hello'

# the route at which we receive data
@app.route('/data', methods=['POST'])
def handle_data():
	global mindwave_has_initialized
	data = request.get_json()
	if not mindwave_has_initialized: 
		mindwave_has_initialized = check_if_initialized(data)
	# else: 
	# 	print 'ok: ', data['attention_esense']
	return 'ok'


def check_if_initialized(data):
	if (data['attention_esense']) > 0:
		print 'ok! navigate to 127.0.0.1:4228'
		return True
	return False
	
if __name__ == "__main__":
	# start a client, give it the url at which data is sent
	mindwave_client = mindwave_client.Client('http://127.0.0.1:4228/data')
	thread.start_new_thread(mindwave_client.run, ())
	app.run(port=4228,debug=True)