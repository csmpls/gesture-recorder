sockets = require './lib/sockets.coffee'
$ = require 'jquery'

userData = require('./lib/models.coffee').userData()
login_view = require './lib/login_view.coffee'
recorder_view = require './lib/recorder_view.coffee'

Bacon = require 'baconjs'
moment = require 'moment'

isTruthy = (item) -> if (item) then true else false
isSignalGood = (data) -> if data['signal_quality'] == 0 then true else false
timediff = (earlier, later) -> moment(later).diff(earlier, 's')

isSignalFresh = (reading_time, now) -> 
	# to be timezone-safe, lets set the day+hour of whatehver reading we get to our day+hour
	reading_time = new Date(reading_time)
	reading_time.setDate(now.getDate())
	reading_time.setHours(now.getHours())
	timediff(reading_time, now) < 15

init = ->

	socket = sockets.setup()

	# dataStream is a Bacon stream of mindwave data
	# we get the data over a websocket connction to the server.
	dataStream = Bacon.fromEventTarget(socket, 'data')

	# initialially, the view is the login view
	idSubmissionStream = login_view.setup(socket, userData)

	# but, switch to recorder view as soon as we get our first mwm data
	dataStream
		.take(1)
		.onValue( () ->
			# setup the view, and retreive a stream of recording requests 
			recordRequestStream = recorder_view.setup(
				socket
				, userData.get('userId')
				, userData.get('electrodePosition')))

	# current mindwave data at any given time
	mindwaveDataProp = dataStream.toProperty(false)

	# stream of bools epresenting whether or not the signal is good 
	# values: true (good signal) / false (bad signal)
	isSignalGoodStream = dataStream.map(isSignalGood)

	isSignalGoodStream.log()

	# stream of bools representing whether or not the signal is fresh
	isSignalFreshStream = mindwaveDataProp
		.sampledBy(Bacon.interval(1000))
		.filter((v) -> 
			isTruthy(v))
		.map((v) -> 
			isSignalFresh(
				v.reading_time
				, new Date()))
		# .log('signal is fresh?')

	console.log 'app launched.'

# launch the app
$(document).ready(() ->
	init() )