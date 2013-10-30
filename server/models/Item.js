var mongoose = require('mongoose')
	, schema = mongoose.Schema
	, ObjectId = schema.ObjectId;

var scheme = schema({
	name: String,
	price: Number,
	category: { type: ObjectId, ref: 'Category' }
});

module.exports = mongoose.model("Item", scheme);