var mongoose = require('mongoose')
	, schema = mongoose.Schema
	, ObjectId = schema.ObjectId;

var scheme = schema({
	name: String,
	code: String,
	manager: { type: Boolean, default: false }
});

scheme.methods.update = function (data) {
	this.name = data.name;
	this.code = data.code;
	this.manager = data.manager;
}

module.exports = mongoose.model("Staff", scheme);

/*
new module.exports({
	name: "Matej",
	code: "1111",
	manager: true
}).save()*/