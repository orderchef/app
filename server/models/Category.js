var mongoose = require('mongoose')
	, schema = mongoose.Schema
	, ObjectId = schema.ObjectId;

var scheme = schema({
	name: String,
	drink: { type: Boolean, default: false },
	hotFood: { type: Boolean, default: false },
	sushi: { type: Boolean, default: false },
	deleted: { type: Boolean, default: false }
});

scheme.methods.update = function (data) {
	this.name = data.name;
	this.drink = data.drink;
	this.hotFood = data.hotFood;
	this.sushi = data.sushi;
}

module.exports = mongoose.model("Category", scheme);