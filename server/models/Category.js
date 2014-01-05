var mongoose = require('mongoose')
	, schema = mongoose.Schema
	, ObjectId = schema.ObjectId;

var scheme = schema({
	name: String,
	deleted: { type: Boolean, default: false },
	printers: [String]
});

scheme.methods.update = function (data) {
	this.name = data.name;
	this.printers = [];
	for (var i = 0; i < data.printers.length; i++) {
		this.printers.push(data.printers[i]);
	}
}

module.exports = mongoose.model("Category", scheme);