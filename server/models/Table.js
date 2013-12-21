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
	deleted: { type: Boolean, default: false },
	
	delivery: { type: Boolean, default: false },
	takeaway: { type: Boolean, default: false }
});

scheme.methods.update = function (data) {
	this.name = data.name;
	this.notes = data.notes;
	
	this.delivery = data.delivery;
	this.takeaway = data.takeaway;
	
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

scheme.methods.sortFunction = function (a, b) {
	if (a.item.name > b.item.name) {
		return 1
	}
	if (a.item.name < b.item.name) {
		return -1;
	}
	
	return 0;
}


module.exports = mongoose.model("Table", scheme);
