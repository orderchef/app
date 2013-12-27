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

function getSpaces (spaces) {
	var spacer = "";
	while (spaces >= 0) {
		spacer += " ";
		spaces--;
	}

	return spacer;
}

scheme.methods.update = function (data) {
	this.notes = data.notes;
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

scheme.methods.print = function (printer, data) {
	var self = this;
	
	var table = data.table;
	var employee = data.employee;
	
	const kChars = printer.characters;
	var d = new Date()
	var time = "Time of Order:";
	var time2 = d.getHours() + ":" + d.getMinutes() + "\n";
	time = time + getSpaces(kChars - time.length - time2.length) + time2;
	var date = "Date of Order:";
	var date2 = d.getDate() + "/" + (d.getMonth()+1) + "/" + d.getFullYear() + "\n";
	date = date + getSpaces(kChars - date.length - date2.length) + date2;
	
	var orderedString = "";
	
	var total = 0;
	for (var i = 0; i < self.items.length; i++) {
		var it = self.items[i];
		
		if (it.item.category.printers.length > 0) {
			var found = false;
			for (var x = 0; x < it.item.category.printers.length; x++) {
				if (it.item.category.printers[x] == printer.name) {
					found = true;
					break;
				}
			}
			
			if (!found) continue;
		}
		
		if (printer.prices) {
			// Printer prints prices too
			var val = it.quantity * it.item.price;
			total += val;
			
			var valueString = " £" + val.toFixed(2) + "\n";
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
	
	var tableName = "Table "+ table;
	var tableLength = kChars - tableName.length;
	var spaces = getSpaces(Math.floor((tableLength+1)/2))
	tableName = spaces + tableName;
	
	var _total = "";
	var totalString = "";
	if (printer.prices) {
		_total = " £"+total.toFixed(2)+"\n";
		totalString = "Total:"+getSpaces(kChars - 6 - _total.length)+_total+"\n";
	}
	
	var output = "\
" + tableName +"\n\n\
" + time + "\
" + date + "\
Serviced By " + employee + "\n\n\
Notes: " + self.notes + "\n\n\
Ordered Items:\n" + orderedString + "\n\
"+ totalString + "\
\n";
	console.log(output);
	
	printer.socket.emit('print_data', {
		data: output
	});
}

module.exports = mongoose.model("Order", scheme);