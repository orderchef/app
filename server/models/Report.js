var mongoose = require('mongoose')
	, schema = mongoose.Schema
	, ObjectId = schema.ObjectId;

var scheme = schema({
	created: { type: Date, default: Date.now },
	tables: [{
		table: {
			name: String,
			t: {
				type: ObjectId,
				ref: 'Table'
			}
		},
		itemsSold: Number,
		total: Number
	}],
	total: Number,
	quantity: Number
});

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

scheme.methods.addTable = function (table) {
	var it = -1;
	var tab = null;
	
	for (var i = 0; i < this.tables.length; i++) {
		var t = this.tables[i];
		
		if (t.table.t.equals(table._id)) {
			it = i;
			tab = this.tables[it]; 
			break;
		}
	}
	
	if (it == -1) {
		tab = {};
	}
	
	tab.table = {
		name: table.name,
		t: table._id
	}
	
	if (typeof tab.itemsSold === "undefined") {
		tab.itemsSold = 0;
		tab.total = 0;
	}
	
	for (var i = 0; i < table.items.length; i++) {
		tab.itemsSold += table.items[i].quantity;
		tab.total += (table.items[i].quantity * table.items[i].item.price);
	}
	console.log(tab);
	
	if (it == -1) {
		this.tables.push(tab);
	}
	
	var total = 0;
	var quantity = 0;
	for (var i = 0; i < this.tables.length; i++) {
		console.log(this.tables[i])
		total += this.tables[i].total;
		quantity += this.tables[i].itemsSold;
	}
	this.total = total;
	this.quantity = quantity;
	
	this.save();
}

module.exports = mongoose.model("Report", scheme);
