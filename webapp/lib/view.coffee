$ = require 'jquery'
io = require 'socket.io-client'

exports.setup = () ->
	$('body').append('<p>hi from view</p>')
	$('body').append('<img src="static/assets/wand.gif">')

	socket = io.connect('ws://localhost:5000')
	socket.emit('connected', 'sup')

	socket.on('sup', (data) -> 
		console.log 'from server: ', data)

	socket.on('data', (data) -> 
		console.log 'mw data: ', data)
