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

module.exports = mongoose.model("Employee", scheme);

module.exports.findOne({
	name: "OrderChef Admin"
}, function(err, admin) {
	if (err || admin) return;
	
	console.log("Creating admin");
	
	admin = new module.exports({
		name: "OrderChef Admin",
		code: "1111",
		manager: true
	})
	admin.save()
})