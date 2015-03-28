$ = require 'jquery'

login_template = ->
	_.template('''
		<p>hi!</p>
		<img src="static/assets/wand.gif">
		''')

exports.setup = () ->
	$('body').html(login_template()())
