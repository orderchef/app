var mongoose = require('mongoose')
	, schema = mongoose.Schema
	, ObjectId = schema.ObjectId
	, async = require('async')
	, common = require('../common')
	, moment = require('moment')
	, winston = require('winston')

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
	
	this.orders = [];
	for (var i = 0; i < data.orders.length; i++) {
		this.orders.push(mongoose.Types.ObjectId(data.orders[i]));
	}
}

scheme.methods.print = function (printer, data, justOrders) {
	if (typeof justOrders === 'undefined') {
		justOrders = false;
	}
	
	var self = this;
	
	var table = self.table.name;
	var employee = data.employee;
	
	const kChars = printer.characters;
	
	var datetime = common.getDatetime(kChars, new Date());
	
	var orderedString = "";
	
	var _total = 0;
	for (var x = 0; x < self.orders.length; x++) {
		var order = self.orders[x];
		
		if (!justOrders) {
			//orderedString += "Order placed "+moment(order.created).format('ddd Do/MM/YY HH:mm')+"\n";
			orderedString += " Notes: " + order.notes + "\n\n";
		}
		
		var orderData = order.getOrderData(printer, true);
		orderedString += orderData.data;
		var total = orderData.total;
		
		if (orderData.printedData == false && force == false) {
			// The printer doesn't have any data to be printed
			return;
		}
		
		if (justOrders) {
			orderedString += "\n";
		} else {
			var ___total = " "+total.toFixed(2)+" GBP\n";
			var totalForOrder = "Total for Order:";
			orderedString += "\n";
			orderedString += totalForOrder + common.getSpaces(kChars - totalForOrder.length - ___total.length)+___total+"\n";
		}
		
		_total += total;
	}
	
	var tableName = "Table "+ table;
	var tableLength = kChars - tableName.length;
	var spaces = common.getSpaces(Math.floor((tableLength+1)/2))
	tableName = spaces + tableName;
	
	var totalString = "";
	if (!justOrders) {
		var __total = "";
		if (printer.prices) {
			__total = " "+_total.toFixed(2)+" GBP\n";
			totalString = "Total:"+common.getSpaces(kChars - 6 - __total.length)+__total+"\n";
		}
	}
	
	var servicedBy = "Serviced By " + employee;
	servicedBy = common.getSpaces(Math.floor((kChars - servicedBy.length)/2)) + servicedBy;
	
	var output = "\
" + tableName +"\n\n\
" + datetime + "\
" + servicedBy + "\n\n\
" + orderedString + "\
"+ totalString + "\
\n";
	winston.info(output);
	
	var printData = {
		data: output
	};
	if (!justOrders) {
		printData.address = true;
		printData.logo = true;
		printData.footer = true;
	}
	printer.socket.emit('print_data', printData);
}

scheme.statics.aggregate = function (socket, groups) {
	var finalData = {
		orders: [],
		total: 0,
		quantity: 0
	};
	
	for (var g = 0; g < groups.length; g++) {
		var group = groups[g];
		var date = group.clearedAt;
		
		var t = {
			total: 0,
			quantity: 0,
			items: [],
			delivery: group.table.delivery,
			takeaway: group.table.takeaway,
			time: Math.round(date.getTime()/1000)
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
	
	socket.emit('get.reports', {
		aggregated: finalData,
		//groups: groups
	})
}

module.exports = mongoose.model("OrderGroup", scheme);