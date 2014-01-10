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

function getSpaces (spaces) {
	var spacer = "";
	while (spaces >= 0) {
		spacer += " ";
		spaces--;
	}

	return spacer;
}

scheme.methods.update = function (data) {
	try {
		this.table = mongoose.Types.ObjectId(data.table);
	} catch (e) {
		this.table = null;
	}
	
	this.orders = [];
	for (var i = 0; i < data.orders.length; i++) {
		this.orders.push(mongoose.Types.ObjectId(data.orders[i]));
	}
}

scheme.methods.print = function (printer, data) {
	var self = this;
	
	var table = self.table.name;
	var employee = data.employee;
	
	const kChars = printer.characters;
	var d = new Date()
	var datetime = d.getDate() + "/" + (d.getMonth()+1) + "/" + d.getFullYear() + " at " + d.getHours() + ":" + d.getMinutes() + "\n";
	datetime = getSpaces(kChars - datetime.length) + datetime;
	
	var orderedString = "";
	
	var _total = 0;
	for (var x = 0; x < self.orders.length; x++) {
		var order = self.orders[x];
		
		orderedString += "Order placed "+order.created+"\n";
		var total = 0;
		for (var i = 0; i < order.items.length; i++) {
			var it = order.items[i];
		
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
		orderedString += "\nTotal for Order: £"+total+"\n\n";
		
		_total += total;
	}
	
	var tableName = "Table "+ table;
	var tableLength = kChars - tableName.length;
	var spaces = getSpaces(Math.floor((tableLength+1)/2))
	tableName = spaces + tableName;
	
	var __total = "";
	var totalString = "";
	if (printer.prices) {
		__total = " £"+_total.toFixed(2)+"\n";
		totalString = "Total:"+getSpaces(kChars - 6 - __total.length)+__total+"\n";
	}
	
	var output = "\
" + tableName +"\n\n\
" + datetime + "\
Serviced By " + employee + "\n\n\
" + orderedString + "\
"+ totalString + "\
\n";
	console.log(output);
	
	printer.socket.emit('print_data', {
		data: output
	});
}

scheme.statics.aggregate = function (socket, groups) {
	var finalData = {
		orders: [],
		total: 0,
		quantity: 0
	};
	
	for (var g = 0; g < groups.length; g++) {
		var group = groups[g];
		var date = new Date(group.clearedAt);
		var t = {
			total: 0,
			quantity: 0,
			items: [],
			delivery: group.table.delivery,
			takeaway: group.table.takeaway,
			time: Math.floor(date.getTime()/1000)
		}; // order
		
		for (var o = 0; o < group.orders.length; o++) {
			var order = group.orders[o];
			
			for (var i = 0; i < order.items.length; i++) {
				var item = order.items[i];
				
				t.total += item.quantity * item.item.price;
				t.quantity += item.quantity;
				
				var found = false;
				for (var x = 0; x < t.items.length; x++) {
					if (t._id == item.item._id.toString()) {
						found = x;
						break;
					}
				}
				
				if (found === false) {
					t.items.push({
						_id: item.item._id.toString(),
						category: item.item.category,
						name: item.item.name,
						price: item.item.price,
						total: item.quantity * item.item.price,
						quantity: item.quantity
					})
				} else {
					t.items[found].quantity += item.quantity;
					t.items[found].total += item.quantity * item.item.price;
				}
			}
		}
		
		finalData.orders.push(t)
		finalData.total += t.total;
		finalData.quantity += t.quantity;
	}
	
	console.log(finalData);
	
	socket.emit('get.reports', {
		aggregated: finalData,
		//groups: groups
	})
}

module.exports = mongoose.model("OrderGroup", scheme);