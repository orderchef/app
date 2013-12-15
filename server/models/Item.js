var mongoose = require('mongoose')
	, schema = mongoose.Schema
	, ObjectId = schema.ObjectId;

var scheme = schema({
	disabled: { type: Boolean, default: false },
	name: String,
	price: Number,
	category: { type: ObjectId, ref: 'Category' }
});

scheme.methods.update = function (data) {
	this.name = data.name;
	this.price = data.price;
	this.category = data.category;
}

module.exports = mongoose.model("Item", scheme);