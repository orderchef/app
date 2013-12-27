var mongoose = require('mongoose')
	, schema = mongoose.Schema
	, ObjectId = schema.ObjectId
	, async = require('async')

var scheme = schema({
	orders: [{
		type: ObjectId,
		ref: 'Order'
	}],
	table: {
		type: ObjectId,
		ref: 'Table'
	},
	created: {
		type: Date,
		default: Date.now
	},
	cleared: {
		type: Boolean,
		default: false
	},
	clearedAt: {
		type: Date
	}
})

scheme.methods.update = function (data) {
	try {
		this.table = mongoose.Types.ObjectId(data.table);
	} catch (e) {
		this.table = null;
	}
	
	this.created = data.created;
	this.cleared = data.cleared;
	this.clearedAt = data.clearedAt;
	
	this.orders = [];
	for (var i = 0; i < data.orders.length; i++) {
		this.orders.push(mongoose.Types.ObjectId(data.orders[i]));
	}
}

module.exports = mongoose.model("OrderGroup", scheme);