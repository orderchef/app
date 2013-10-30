var mongoose = require('mongoose')
	, schema = mongoose.Schema
	, ObjectId = schema.ObjectId;

var scheme = schema({
	name: String,
	items: [{
		item: { type: ObjectId, ref: 'Item' },
		quantity: Number
	}]
});

module.exports = mongoose.model("Table", scheme);