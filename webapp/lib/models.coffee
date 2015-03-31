Backbone = require 'backbone'

MindwaveData = Backbone.Model.extend(
	defaults: 
		payload: null
		isSignalFresh: false
	initialize: () -> console.log 'mw data model initialized'
	setPayload: (v) -> @set(payload: v)
	setFreshness: (v) -> @set(isSignalFresh: v)
)

UserData = Backbone.Model.extend(
	defaults:
		userId: null
		electrodePosition: null
	initialize: () -> console.log 'user model initialized'
	setUserId: (v) -> @set(userId: v)
	setElectrodePosition: (v) -> @set(electrodePosition: v)
)

exports.mindwaveData = () -> new MindwaveData()

exports.userData = () -> new UserData()