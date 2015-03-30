io = require './socket.io.min.js'
Bacon = require 'baconjs'


# returns a bacon stream of the data
exports.setup = () ->

	socket = io.connect('http://localhost:5000')
	socket.emit('connected', 'sup')

	socket.on('server_says', (data) -> 
		console.log 'server says: ', data)

	# data from the mindwave mobile
	socket.on('data', (data) -> 
		console.log 'mw data: ', data)

	socket	