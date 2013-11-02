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

scheme.methods.update = function (data) {
	this.name = data.name;
}

module.exports = mongoose.model("Table", scheme);