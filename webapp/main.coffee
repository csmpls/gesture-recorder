example_view = require './lib/view.coffee'
$ = require('jquery')

init = ->
	console.log 'main app launching'
	example_view.setup()
	console.log 'main app done+launched'

# launch the app
$(document).ready(() ->
	init() )
