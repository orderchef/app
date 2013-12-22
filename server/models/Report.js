var mongoose = require('mongoose')
	, schema = mongoose.Schema
	, ObjectId = schema.ObjectId;

var scheme = schema({
	created: { type: Date, default: Date.now },
	
	delivery: { type: Boolean, default: false },
	takeaway: { type: Boolean, default: false },
	
	name: String,
	notes: String,
	
	items: [{
		name: String,
		category: String,
		price: Number,
		quantity: Number,
		notes: { type: String, default: "" }
	}],
	
	total: Number,
	quantity: Number
});

scheme.statics.addOrder = function (table) {
	var r = new module.exports({
		delivery: table.delivery,
		takeaway: table.takeaway,
		
		name: table.name,
		notes: table.notes,
		
		total: 0,
		quantity: 0
	})
	
	for (var i = 0; i < table.items.length; i++) {
		var it = table.items[i];
		r.items.push({
			quantity: it.quantity,
			notes: it.notes,
			name: it.item.name,
			category: it.item.category.name,
			price: it.item.price
		})
		
		r.total += it.item.price * it.quantity;
		r.quantity += it.quantity;
	}
	
	return r;
}

scheme.statics.getTodaysReport = function (cb) {
	var today = new Date();
	var t = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 0, 0, 0, 0);
	var tm = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 23, 59, 59, 999);
	module.exports.findOne({
		created: {
			$gte: t,
			$lte: tm
		}
	}, function(err, report) {
		if (err) throw err;
		
		if (err || !report) {
			report = new module.exports();
		}
		
		cb(report);
	})
}

module.exports = mongoose.model("Report", scheme);
