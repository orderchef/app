var mongoose = require('mongoose')
	, schema = mongoose.Schema
	, ObjectId = schema.ObjectId;

var scheme = schema({
	name: String,
	items: [{
		item: { type: ObjectId, ref: 'Item' },
		quantity: Number,
		notes: { type: String, default: "" }
	}],
	notes: String,
	deleted: { type: Boolean, default: false }
});

scheme.methods.update = function (data) {
	this.name = data.name;
	this.notes = data.notes;
	
	for (var i = 0; i < data.items.length; i++) {
		for (var x = 0; x < this.items.length; x++) {
			if (data.items[i]._id == this.items[x]._id.toString()) {
				this.items[x].notes = data.items[i].notes;
				this.items[x].quantity = data.items[i].quantity;
				this.items[x].save()
				
				break;
			}
		}
	}
}

module.exports = mongoose.model("Table", scheme);
