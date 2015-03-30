$ = require 'jquery'
_ = require 'lodash'
bacon$ = require 'bacon.jquery'
baconModel = require 'bacon.model'

userData = require('./models.coffee').userData()

nonEmpty = (v) -> v.length > 0 
setEnabled = (element, enabled) -> element.attr("disabled", !enabled) 

login_template = ->
	_.template('''
		<p>hi!</p>
		<img src="static/assets/ear_positions.png">
		<br>
		User ID: <input type="text" id="userIdInput"/>
		<br>
		Electrode position:
		<select id="electrodePosition">
			<option value = "ELB">ELB</option>
			<option value = "ELA">ELA</option>
			<option value = "ELH">ELH</option>
			<option value = "ELE">ELE</option>
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

exports.setup = (socket) ->

	$('body').html(login_template()())

	$userIdInput = $('#userIdInput')
	$electrodePositionSelection = $('#electrodePosition')
	$connectButton = $('#connectButton')

	userIdInputProperty = bacon$.textFieldValue($userIdInput)
		.debounce(150)
		.skipDuplicates()

	# disable the connect button until a username is entered
	# userIdInputProperty.map(nonEmpty)
	# 	.assign(setEnabled, $connectButton)

	connectButtonStream = $connectButton.asEventStream('click')
	userIdInputProperty
		.sampledBy(connectButtonStream)
		.onValue((v) ->

			# send a message to the server to connect to mindwave
			socket.emit('connect', v)

			# store the user ID and electrode position in our backbone model
			userData.setUserId(v)
			# TODO make this a little cleaner somehow, baconify it perhaps
			userData.setElectrodePosition( $electrodePositionSelection.val() )

			# display the connection screen
			$('body').html(connecting_template()()))







































