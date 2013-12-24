var mongoose = require('mongoose')
	, schema = mongoose.Schema
	, ObjectId = schema.ObjectId
	, async = require('async')

var scheme = schema({
	items: [{
		item: { type: ObjectId, ref: 'Item' },
		quantity: Number,
		notes: {
			type: String,
			default: ""
		}
	}],
	notes: {
		type: String,
		default: ""
	},
	created: {
		type: Date,
		default: Date.now
	},
	printed: {
		type: Boolean,
		default: false
	},
	printedAt: {
		type: Date
	}
})

module.exports = mongoose.model("Order", scheme);