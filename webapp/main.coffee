login_view = require './lib/login_view.coffee'
sockets = require './lib/sockets.coffee'
$ = require('jquery')

init = ->
	login_view.setup()
	sockets.setup()
	console.log 'app launched.'

# launch the app
$(document).ready(() ->
	init() )