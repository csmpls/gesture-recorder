$ = require 'jquery'
_ = require 'lodash'
Bacon = require 'baconjs'
bacon$ = require 'bacon.jquery'
baconModel = require 'bacon.model'

userData = require('./models.coffee').userData()


recorder_screen_template = ->
	_.template('''

		<h1 id="userIdDisplay">
			<%= userId %>, welcome to gesture-recorder!
		</h1>

		<p> <i> Position: <%= electrodePosition %>. </i> </p>

		<p> pick a mental gesture to record: </p>

		<select id="mentalGestures">
		<% _.forEach(gesture_list,  function(gesture) { %>
			<option value = "<%= gesture %>"> <%= gesture %> </option>
		<% }) %>
		</select>

		<br>
		<button id = "recordGestureButton">Record a sample of this gesture!</button>
		''')

currently_recording_template = ->
	_.template('''

		<h1>
			currently recording! 
		</h1>

		<p> <i> ,,,,,, </i> </p>

		''')

set_to_recorder_screen = (userId, electrodePosition, gesture_list) -> 
	$('body').html(recorder_screen_template()(
		userId: userId
		electrodePosition: electrodePosition
		gesture_list: gesture_list))

setup = (socket, userId, electrodePosition) ->

	gestures = ['color', 'pass', 'sport', 'finger'] 

	set_to_recorder_screen(userId, electrodePosition, gestures)

	$mentalGestureSelection = $('#mentalGestures')
	$recordButton = $('#recordGestureButton')
	gestureSelectionModel = bacon$.selectValue($mentalGestureSelection)

	recordRequestStream = $recordButton.asEventStream('click')
		.map(() ->
			userId: userId
			electrodePosition: electrodePosition
			gesture: gestureSelectionModel.get() )

	recordRequestStream
		.onValue((v) ->
			socket.emit('record', v))

	# a stream of server's messages that it has started to record
	startRecordingStream = Bacon.fromEventTarget(socket, 'start_record')
	endRecordingStream = Bacon.fromEventTarget(socket, 'end_record')

	startRecordingStream.onValue( () ->
		console.log 'start recording event'
		$('body').html(currently_recording_template()()))

	# set back to record screen whenever gesture recording ends 
	endRecordingStream.onValue( () -> 
		re_setup(socket, userId, electrodePosition, gestures))

	# return a stream of recording requests
	recordRequestStream

re_setup = (socket, userId, electrodePosition, gestures) -> 
	setup(socket
		, userId
		, electrodePosition
		, gestures)

exports.setup = setup