io = require('./lib/socket.io.min.js')
Bacon = require 'baconjs'

exports.setup = () ->
	socket = io.connect('http://localhost:5000')
	socket.emit('connected', 'sup')

	socket.on('sup', (data) -> 
		console.log 'server says: ', data)

	# data from the mindwave mobile
	socket.on('data', (data) -> 
		console.log 'mw data: ', data)

	# a property representing the signal quality of the device
	# signalQualityProp = Bacon.fromEvent(socket, 'on', 'data')
	# 	.log()