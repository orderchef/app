var mongoose = require('mongoose')
	, schema = mongoose.Schema
	, ObjectId = schema.ObjectId
	, async = require('async')
	, models = require('./')

function getSpaces (spaces) {
	var spacer = "";
	while (spaces >= 0) {
		spacer += " ";
		spaces--;
	}

	return spacer;
}

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

scheme.statics.getTable = function (id, cb) {
	module.exports.findById(id)
		.populate('items.item')
		.exec(function(err, table) {
		if (err) { cb(err, null); return; }
		
		async.each(table.items, function(item, cb) {
			item.item.populate('category', cb)
		}, function(err) {
			cb(err, table);
		})
	})
}

scheme.methods.printOrder = function () {
	var table = this;
	
	var d = new Date()
	var date = "Time of Order:";
	var date2 = d.getHours() + ":" + d.getMinutes() + "\n";
	date = date + getSpaces(31 - date.length - date2.length) + date2;
	var orderedString = "";
	
	var total = 0;
	for (var i = 0; i < table.items.length; i++) {
		var it = table.items[i];
		var val = it.quantity * it.item.price;
		
		var valueString = " (GBP) " + val.toFixed(2) + "\n";
		var string = it.quantity+" "+it.item.name+" ";
		
		var spaces = 31 - valueString.length - string.length;
		orderedString += string + getSpaces(spaces) + valueString;
		
		total += it.quantity * it.item.price;
	}
	
	var tableName = "Table "+ table.name;
	var tableLength = 31 - tableName.length;
	var spaces = getSpaces(Math.floor((tableLength+1)/2))
	tableName = spaces + tableName;
	
	var total = " (GBP) "+total.toFixed(2)+"\n";
	var output = "\
" + tableName +"\n\n\
" + date + "\
Notes: " + table.notes + "\n\n\
Ordered Items:\n" + orderedString + "\n\n\
Total:"+getSpaces(31 - 6 - total.length)+total+"\n\
\n\n";
	console.log(output);
	
	for (var i = 0; i < models.printers.length; i++) {
		models.printers[i].socket.emit('print_data', {
			data: output
		});
	}
}


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

scheme.methods.resetTable = function () {
	this.items = [];
	this.notes = "";
}

module.exports = mongoose.model("Table", scheme);

setTimeout(function() {
	if (!models.printers) {
		models = require('./')
	}
}, 500)