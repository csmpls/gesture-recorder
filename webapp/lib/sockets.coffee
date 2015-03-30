io = require './socket.io.min.js'
Bacon = require 'baconjs'
moment = require 'moment'

isSignalGood = (data) -> if data['signal_quality'] == 0 then true else false
timediff = (earlier, later) -> moment(later).diff(earlier, 's')
isSignalFresh = (data, now) -> if timediff(new Date(data.reading_time), now) < 20 then true else false
isTruthy = (item) -> if (item) then true else false

exports.setup = () ->

	mindwaveData = null

	socket = io.connect('http://localhost:5000')
	socket.emit('connected', 'sup')

	socket.on('server_says', (data) -> 
		console.log 'server says: ', data)

	# data from the mindwave mobile
	socket.on('data', (data) -> 
		mindwaveData = data
		console.log 'mw data: ', data)

	# boolean property representing whether or not the signal is good 
	# values: true (good signal) / false (bad signal)
	isSignalGoodProp = Bacon.fromEventTarget(socket, 'data')
		.map(isSignalGood)
		.toProperty(false)

	signalFreshness = Bacon.interval(1000)
		.filter(() -> isTruthy(mindwaveData))
		.map(() -> isSignalFresh(mindwaveData, new Date()))
		.log('signal is fresh?')
