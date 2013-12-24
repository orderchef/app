var mongoose = require('mongoose')
	, schema = mongoose.Schema
	, ObjectId = schema.ObjectId
	, async = require('async')

var scheme = schema({
	orders: [{
		type: ObjectId,
		ref: 'Order'
	}],
	table: {
		type: ObjectId,
		ref: 'Table'
	},
	created: {
		type: Date,
		default: Date.now
	},
	cleared: {
		type: Boolean,
		default: false
	},
	clearedAt: {
		type: Date
	}
})

module.exports = mongoose.model("OrderGroup", scheme);