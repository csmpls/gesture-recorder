io = require './socket.io.min.js'
Bacon = require 'baconjs'


# returns a bacon stream of the data
exports.setup = () ->

	socket = io.connect('http://localhost:5000')

	# server messages to display on the console
	socket.on('server_says', (data) -> 
		console.log 'server says: ', data)

	# data from the mindwave mobile
	socket.on('data', (data) -> data)

	# message that the server is recording / is done recording
	socket.on('start_record', (msg) -> msg)
	socket.on('end_record', (msg) -> msg)

