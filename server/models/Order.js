var mongoose = require('mongoose')
	, schema = mongoose.Schema
	, ObjectId = schema.ObjectId
	, async = require('async')
	, common = require('../common')
	, winston = require('winston')

var scheme = schema({
	items: [{
		item: { type: ObjectId, ref: 'Item' },
		quantity: Number,
		notes: {
			type: String,
			default: ""
		},
		price: Number
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
	this.items = [];
	
	for (var i = 0; i < data.items.length; i++) {
		var it = data.items[i];
		
		this.items.push({
			item: mongoose.Types.ObjectId(it.item),
			quantity: it.quantity,
			notes: it.notes,
			price: it.price
		});
	}
}

scheme.methods.getOrderData = function (printer, opts) {
	if (typeof opts === 'undefined') {
		opts = {};
	}
	
	const kChars = printer.characters;
	var self = this;
	
	var orderedString = "";
	
	var printedData = false;
	for (var i = 0; i < self.items.length; i++) {
		var it = self.items[i];
		
		if (it.item.category.printers.length > 0) {
			var found = false;
			for (var x = 0; x < it.item.category.printers.length; x++) {
				if (opts.force == true) {
					found = true;
					break;
				}
				
				if (it.item.category.printers[x] == printer.name) {
					found = true;
					break;
				}
			}
			
			if (!found) continue;
		}
		printedData = true;
		
		if (opts.prices) {
			// Printer prints prices too
			var val = it.quantity * it.price;
			
			var valueString = " " + val.toFixed(2) + " GBP\n";
			var string = it.quantity + " " + it.item.name + " ";
			
			var spaces = kChars - valueString.length - string.length;
			orderedString += string + common.getSpaces(spaces) + valueString;
		} else {
			// Just food items
			orderedString += it.quantity + " " + it.item.name + "\n";
		}
		// notes (if any)
		if (opts.notes && it.notes.trim().length > 0) {
			orderedString += " Notes: "+it.notes + "\n";
		}
	}
	
	return {
		printedData: printedData,
		data: orderedString
	}
}

scheme.methods.print = function (printer, data) {
	var self = this;
	
	var table = data.table.name;
	var employee = data.employee;
	
	const kChars = printer.characters;
	
	var orderData = this.getOrderData(printer, {
		notes: true
	});
	if (orderData.printedData == false) {
		// The printer doesn't have any data to be printed
		return;
	}
	
	var orderedString = orderData.data;
	
	var d = new Date();
	if (this.printedAt) {
		d = this.printedAt;
	}
	var datetime = common.getDatetime(kChars, d);
	
	var servicedBy = "Serviced By " + employee;
	servicedBy = common.getSpaces(Math.floor((kChars - servicedBy.length)/2)) + servicedBy;
	
	var notes = "Notes: " + self.notes + "\n\n";
	if (self.notes.length == 0) {
		notes = "";
	}

	var cookingTime = "";
	if (data.cookingTime.length > 0) {
		cookingTime = " Cooking Time: " + data.cookingTime + "\n";
	}
	var customerName = "";
	if (data.customerName && data.customerName.length > 0) {
		customerName = " Customer: " + data.customerName + "\n";
	}
	var telephone = "";
	if (data.telephone.length > 0) {
		telephone = " Telephone: " + data.telephone + "\n";
	}
	var deliveryTime = "";
	if (data.table.takeaway && data.deliveryTime.length > 0) {
		deliveryTime += " Takeaway Time: ";
		deliveryTime += data.deliveryTime + "\n";
	}
	
	var output = "\
\n\n\n\n\
 Order #" + data.orderNumber + "\n\
 " + table +"\n\n\
" + datetime + "\
" + servicedBy + "\n\n\
Ordered Items:\n" + orderedString + "\n\
" + notes + "\
" + cookingTime + "\
" + customerName + "\
" + telephone + "\
" + deliveryTime + "\
\n";
	
	winston.info(output);
	
	printer.socket.emit('print_data', {
		data: output,
		address: false,
		logo: false,
		footer: false
	});
}

module.exports = mongoose.model("Order", scheme);