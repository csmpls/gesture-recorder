$ = require 'jquery'
_ = require 'lodash'
bacon$ = require 'bacon.jquery'
baconModel = require 'bacon.model'
utils = require './utils.coffee'


login_template = ->
	_.template('''
		<p>hi!</p>
		<img src="static/assets/ear_positions.png">
		<br>
		User ID: <input type="text" id="userIdInput"/>
		<br>
		Electrode position:
		<select id="electrodePosition">
			<% _.forEach(electrode_position_list, function (electrode_pos) { %>
				<option value = "<%= electrode_pos %>"> <%= electrode_pos %> </option>
			<% }) %>
		</select>
		<br>
		<button id="connectButton">Connect!</button>
		''')

connecting_template = ->
	_.template('''
		<h1>connecting to device...</h1>
		<img src="static/assets/wand.gif">
		<p>make sure the deivce is turned on + on your head</p>
		''')

exports.setup = (socket, userDataModel) ->

	electrode_position_list = ['ELB', 'ELA', 'ELH', 'ELE', 'normal']

	# render the login template in html body
	$('body').html(login_template()(
		electrode_position_list: electrode_position_list))

	$userIdInput = $('#userIdInput')
	$electrodePositionSelection = $('#electrodePosition')
	$connectButton = $('#connectButton')

	userIdInputProperty = bacon$.textFieldValue($userIdInput)
		.debounce(150)
		.skipDuplicates()

	# disable the connect button until a username is entered
	userIdInputProperty.map(utils.nonEmpty)
		.assign(utils.setEnabled, $connectButton)

	connectButtonStream = $connectButton.asEventStream('click')

	# whatever username the person has entered
	# sampled by a click of the button
	idSubmissionStream = userIdInputProperty
		.sampledBy(connectButtonStream)

	# on submit button click, 
	idSubmissionStream.onValue((v) ->

			# send a message to the server to connect to mindwave
			socket.emit('connect', v)

			# store the user ID and electrode position in our backbone model
			userDataModel.setUserId(v)
			# TODO make this a little cleaner somehow, baconify it perhaps
			userDataModel.setElectrodePosition( $electrodePositionSelection.val() )

			# display the connection screen
			$('body').html(connecting_template()()))

	# export a stream of id submissions
	return idSubmissionStream
