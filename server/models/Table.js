var mongoose = require('mongoose')
	, schema = mongoose.Schema
	, ObjectId = schema.ObjectId
	, async = require('async')
	, winston = require('winston')

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

scheme.methods.printOrder = function (printer) {
	var table = this;
	
	const kChars = 31;
	var d = new Date()
	var time = "Time of Order:";
	var time2 = d.getHours() + ":" + d.getMinutes() + "\n";
	time = time + getSpaces(kChars - time.length - time2.length) + time2;
	var date = "Date of Order:";
	var date2 = d.getDate() + "/" + (d.getMonth()+1) + "/" + d.getFullYear() + "\n";
	date = date + getSpaces(kChars - date.length - date2.length) + date2;
	
	var orderedString = "";
	
	var total = 0;
	for (var i = 0; i < table.items.length; i++) {
		var it = table.items[i];
		
		if (printer.prices) {
			// Printer prints prices too
			var val = it.quantity * it.item.price;
			total += val;
			
			var valueString = " (GBP) " + val.toFixed(2) + "\n";
			var string = it.quantity + " " + it.item.name + " ";
			
			var spaces = kChars - valueString.length - string.length;
			orderedString += string + getSpaces(spaces) + valueString;
		} else {
			// Just food items
			orderedString += it.quantity + " " + it.item.name + "\n";
		}
		// notes (if any)
		if (it.notes.trim().length > 0) {
			orderedString += "  Notes: "+it.notes + "\n";
		}
	}
	
	var tableName = "Table "+ table.name;
	var tableLength = kChars - tableName.length;
	var spaces = getSpaces(Math.floor((tableLength+1)/2))
	tableName = spaces + tableName;
	
	var _total = "";
	var totalString = "";
	if (printer.prices) {
		_total = " (GBP) "+total.toFixed(2)+"\n";
		totalString = "Total:"+getSpaces(kChars - 6 - _total.length)+_total+"\n";
	}
	
	var output = "\
" + tableName +"\n\n\
" + time + "\
" + date + "\
Notes: " + table.notes + "\n\n\
Ordered Items:\n" + orderedString + "\n\
"+ totalString + "\
\n";
	winston.info(output);
	
	printer.socket.emit('print_data', {
		data: output
	});
}

scheme.methods.update = function (data) {
	this.name = data.name;
	this.notes = data.notes;
	
	this.delivery = data.delivery;
	this.takeaway = data.takeaway;
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