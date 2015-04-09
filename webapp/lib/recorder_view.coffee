$ = require 'jquery'
_ = require 'lodash'
Bacon = require 'baconjs'
bacon$ = require 'bacon.jquery'
baconModel = require 'bacon.model'
utils = require './utils.coffee'
userData = require('./models.coffee').userData()

# this template has two divs
# 1 is the prompt for recording gestures
# 2 is the "currently recording" screen
# we hide/show them with jquery
recorder_screen_template = (userId, electrodePosition, gestures) ->
	_.template('''
		<div id = "recordGesturePrompt">
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
		</div>

		<div id = "currentlyRecording">
			<h1> currently recording! </h1>
			<p> <i> ,,,,,, </i> </p>
		</div>
		''')(
		userId: userId
		electrodePosition: electrodePosition
		gesture_list: gestures)

setup = (socket, userId, electrodePosition) ->


    # baseline; close your eyes+focus on your breathing
    # motor imagery; moving extremities (opposite from detected)
    # auditory; play sounds, attend to a particular tone/freq
    # imagined auditory; hear a tune in your head
    # imagine a cube rotating in your head (clockwise/counter)
    # think about whatever you want to think about; but something you can repeat
    # color counting
    # video clip
    # eye - open eye when you hear a tone

	gestures = ['', 'baseline', 'motor imagery', 'auditory'
	, 'imagined auditory', 'imagine rotating a cube'
	, 'eye open static', 'eye open move', 'eye move'
	, 'color count', 'videoclip', 'pass'] 

	# render the template to the DOM
	$('body').html(recorder_screen_template(userId, electrodePosition, gestures))

	# hide the currently recording screen
	$('#currentlyRecording').hide()

	$mentalGestureSelection = $('#mentalGestures')
	$recordButton = $('#recordGestureButton')
	gestureSelectionModel = bacon$.selectValue($mentalGestureSelection)

	# disable the record button if there's no task selected
	gestureSelectionModel
		.map(utils.nonEmpty)
		.assign(utils.setEnabled, $recordButton)

	# emit a record request when button is clicked
	recordRequestStream = $recordButton.asEventStream('click')
		.map(() ->
			userId: userId
			electrodePosition: electrodePosition
			gesture: gestureSelectionModel.get() )

	# emit a record request when button is clicked
	recordRequestStream
		.onValue((v) ->
			socket.emit('record', v))

	# a stream of server's messages that it has started to record
	startRecordingStream = Bacon.fromEventTarget(socket, 'start_record')
	endRecordingStream = Bacon.fromEventTarget(socket, 'end_record')

	# when server says we're recording,
	startRecordingStream.onValue( () ->
		# hide gesture recording prompt
		$('#recordGesturePrompt').hide()
		# show currently recording view
		$('#currentlyRecording').show()
		# reset the gesture selector
		$mentalGestureSelection.val(0)
		gestureSelectionModel.set('')
		utils.setEnabled($recordButton, false))

	# set back to record screen whenever gesture recording ends 
	endRecordingStream.onValue( () -> 
		# show gesture recording prompt
		$('#recordGesturePrompt').show()
		# hide currently recording view
		$('#currentlyRecording').hide())

	# return a stream of recording requests
	recordRequestStream

exports.setup = setup