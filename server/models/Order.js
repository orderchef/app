var mongoose = require('mongoose')
	, schema = mongoose.Schema
	, ObjectId = schema.ObjectId
	, async = require('async')
	, common = require('../common')

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
	},
	postcode: String,
	postcodeDistance: String
})

scheme.methods.update = function (data) {
	this.notes = data.notes;
	this.items = [];
	this.postcode = data.postcode;
	this.postcodeDistance = data.postcodeDistance;
	
	for (var i = 0; i < data.items.length; i++) {
		var it = data.items[i];
		
		this.items.push({
			item: mongoose.Types.ObjectId(it.item),
			quantity: it.quantity,
			notes: it.notes
		});
	}
}

scheme.methods.getOrderData = function (printer) {
	const kChars = printer.characters;
	var self = this;
	
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
			orderedString += string + common.getSpaces(spaces) + valueString;
		} else {
			// Just food items
			orderedString += it.quantity + " " + it.item.name + "\n";
		}
		// notes (if any)
		if (it.notes.trim().length > 0) {
			orderedString += "  Notes: "+it.notes + "\n";
		}
	}
	
	if (self.postcode && self.postcode.length > 0) {
		orderedString += "\nPostcode: "+self.postcode+"\n";
		orderedString += "Calculated Distance: "+self.postcodeDistance+"\n";
	}
	
	return {
		data: orderedString,
		total: total
	}
}

scheme.methods.print = function (printer, data) {
	var self = this;
	
	var table = data.table;
	var employee = data.employee;
	
	const kChars = printer.characters;
	
	var orderData = this.getOrderData(printer);
	var orderedString = orderData.data;
	var total = orderData.total;
	
	var d = new Date();
	if (this.printedAt) {
		d = this.printedAt;
	}
	var datetime = common.getDatetime(kChars, d);
	
	var _total = "";
	var totalString = "";
	if (printer.prices) {
		_total = " £"+total.toFixed(2)+"\n";
		totalString = "Total:"+common.getSpaces(kChars - 6 - _total.length)+_total+"\n";
	}
	
	var tableName = "Table "+ table;
	var tableLength = kChars - tableName.length;
	tableName = common.getSpaces(Math.floor((tableLength+1)/2)) + tableName;
	
	var servicedBy = "Serviced By " + employee;
	servicedBy = common.getSpaces(Math.floor((kChars - servicedBy.length)/2)) + servicedBy;
	
	var output = "\
" + tableName +"\n\n\
" + datetime + "\
" + servicedBy + "\n\n\
Notes: " + self.notes + "\n\n\
Ordered Items:\n" + orderedString + "\n\
"+ totalString + "\
\n";
	
	console.log("To Printer #"+printer.name);
	console.log(output);
	
	printer.socket.emit('print_data', {
		data: output
	});
}

module.exports = mongoose.model("Order", scheme);