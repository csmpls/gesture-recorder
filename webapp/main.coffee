sockets = require './lib/sockets.coffee'
$ = require 'jquery'

mindwaveData = require('./lib/models.coffee').mindwaveData()
userData = require('./lib/models.coffee').userData()
login_view = require './lib/login_view.coffee'
recorder_view = require './lib/recorder_view.coffee'

Bacon = require 'baconjs'
moment = require 'moment'

isTruthy = (item) -> if (item) then true else false
isSignalGood = (data) -> if data['signal_quality'] == 0 then true else false
timediff = (earlier, later) -> moment(later).diff(earlier, 's')

isSignalFresh = (data, now) -> if timediff(new Date(data.reading_time), now) < 5 then true else false

init = ->

	socket = sockets.setup()

	# dataStream is a Bacon stream of mindwave data
	# we get the data over a websocket connction to the server.
	dataStream = Bacon.fromEventTarget(socket, 'data')

	# update the backbone model every time we get mwm data
	dataStream.onValue((v) -> mindwaveData.setPayload(v))

	# initialially, the view is the login view
	idSubmissionStream = login_view.setup(socket, userData)

	# but, switch to recorder view as soon as we get our first mwm data
	# (if they navigated away from the page, e.g., they shouldnt have to re-connect)
	dataStream
		.take(1)
		.onValue( () ->
			# setup the view, and retreive a stream of recording requests 
			recordRequestStream = recorder_view.setup(
				socket
				, userData.get('userId')
				, userData.get('electrodePosition'))

			recordRequestStream
				.onValue( (v) ->
					console.log 'record request!', v))

	# stream of bools epresenting whether or not the signal is good 
	# values: true (good signal) / false (bad signal)
	isSignalGoodStream = dataStream.map(isSignalGood)

	# stream of bools representing whether or not the signal is fresh
	isSignalFreshStream = Bacon.interval(5)
		.filter(() -> 
			isTruthy(mindwaveData.get('payload')))
		.map(() -> 
			isSignalFresh(
				mindwaveData.get('payload')
				, new Date()))
		.skipDuplicates()
		.log('signal is fresh?')

	# side-effect: set freshness in backbone model
	isSignalFreshStream
		.onValue((v) ->
			mindwaveData.setFreshness(v))

	console.log 'app launched.'

# launch the app
$(document).ready(() ->
	init() )