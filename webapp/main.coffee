login_view = require './lib/login_view.coffee'
sockets = require './lib/sockets.coffee'
$ = require 'jquery'

mindwaveData = require('./lib/models.coffee').mindwaveData()

Bacon = require 'baconjs'
moment = require 'moment'

isTruthy = (item) -> if (item) then true else false
isSignalGood = (data) -> if data['signal_quality'] == 0 then true else false
timediff = (earlier, later) -> moment(later).diff(earlier, 's')
isSignalFresh = (data, now) -> if timediff(new Date(data.reading_time), now) < 20 then true else false

init = ->

	socket = sockets.setup()

	login_view.setup(socket)

	# dataStream is a Bacon stream of mindwave data
	# we get the data over a websocket connction to the server.
	dataStream = Bacon.fromEventTarget(socket, 'data')

	dataStream.onValue((v) -> mindwaveData.setPayload(v))

	# stream of bools epresenting whether or not the signal is good 
	# values: true (good signal) / false (bad signal)
	isSignalGoodStream = dataStream.map(isSignalGood).log()

	# stream of bools representing whether or not the signal is fresh
	isSignalFreshStream = Bacon.interval(1000)
		.filter(() -> 
			isTruthy(mindwaveData.get('payload')))
		.map(() -> 
			isSignalFresh(
				mindwaveData.get('payload')
				, new Date()))
		.log('signal is fresh?')

	isSignalFreshStream
		# side-effect: set freshness in backbone model
		.onValue((v) ->
			mindwaveData.setFreshness(v))

	console.log 'app launched.'

# launch the app
$(document).ready(() ->
	init() )