Backbone = require 'backbone'

UserData = Backbone.Model.extend(
	defaults:
		userId: null
		electrodePosition: null
	# initialize: () -> console.log 'user model initialized'
	setUserId: (v) -> @set(userId: v)
	setElectrodePosition: (v) -> @set(electrodePosition: v)
)

exports.userData = () -> new UserData()

exports.mindwaveData = {}