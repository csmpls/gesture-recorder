example_view = require './lib/view.coffee'
sockets = require './lib/sockets.coffee'
$ = require('jquery')

init = ->
	console.log 'main app launching'
	example_view.setup()
	sockets.setup()
	console.log 'main app done+launched'

# launch the app
$(document).ready(() ->
	init() )
