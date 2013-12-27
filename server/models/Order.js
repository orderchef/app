var mongoose = require('mongoose')
	, schema = mongoose.Schema
	, ObjectId = schema.ObjectId
	, async = require('async')

var scheme = schema({
	items: [{
		item: { type: ObjectId, ref: 'Item' },
		quantity: Number,
		notes: {
			type: String,
			default: ""
		}
	}],
	notes: {
		type: String,
		default: ""
	},
	created: {
		type: Date,
		default: Date.now
	},
	printed: {
		type: Boolean,
		default: false
	},
	printedAt: {
		type: Date
	}
})

scheme.methods.update = function (data) {
	this.notes = data.notes;
	this.created = data.created;
	this.printed = data.printed;
	this.printedAt = data.printedAt;
	this.items = [];
	
	for (var i = 0; i < data.items.length; i++) {
		var it = data.items[i];
		
		this.items.push({
			item: mongoose.Types.ObjectId(it.item),
			quantity: it.quantity,
			notes: it.notes
		});
	}
}

module.exports = mongoose.model("Order", scheme);