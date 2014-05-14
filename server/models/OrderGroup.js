var mongoose = require('mongoose')
	, schema = mongoose.Schema
	, ObjectId = schema.ObjectId
	, async = require('async')
	, common = require('../common')
	, moment = require('moment')
	, winston = require('winston')
	, Discount = require('./Discount')
	, Order = require('./Order')
	, bugsnag = require('bugsnag')

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
	},
	
	orderNumber: {
		type: Number,
		default: 0
	},
	orderNumber_locked: {
		type: Boolean,
		default: false
	},
	orderNumber_generated: Date,

	postcode: String,
	postcodeDistance: String,
	deliveryTime: String,
	cookingTime: String,
	telephone: String,
	customerName: String,
	discounts: [{
		type: ObjectId,
		ref: 'Discount'
	}],
	orderTotal: Number,
	discountTotal: Number,
	printouts: [{
		employee: String,
		time: Date
	}],
});

scheme.methods.updateTotal = function(callback) {
	var self = this;

	self.populate({
		path: 'orders',
		select: 'items',
		options: {
			lean: true
		}
	}, function(err) {
		if (err) throw err;

		var total = 0;
		for (var i = 0; i < self.orders.length; i++) {
			var order = self.orders[i];

			for (var x = 0; x < order.items.length; x++) {
				var item = order.items[x];

				total += item.quantity * item.price;
			}
		}

		self.orderTotal = total;

		callback();
	});
}

scheme.methods.update = function (data) {
	try {
		this.table = mongoose.Types.ObjectId(data.table);
	} catch (e) {
		this.table = null;
	}

	this.postcode = data.postcode;
	this.postcodeDistance = data.postcodeDistance;
	this.deliveryTime = data.deliveryTime;
	this.cookingTime = data.cookingTime;
	this.telephone = data.telephone;
	this.customerName = data.customerName;

	this.orders = [];
	for (var i = 0; i < data.orders.length; i++) {
		var id = null;
		try {
			id = mongoose.Types.ObjectId(data.orders[i]);
		} catch (e) {
			bugsnag.notify(new Error("Invalid order id"), {
				data: data
			});
			continue;
		}

		this.orders.push(id);
	}

	this.discounts = [];
	if (!data.discounts) {
		return;
	}
	for (var i = 0; i < data.discounts.length; i++) {
		var id = null;
		try {
			id = mongoose.Types.ObjectId(data.discounts[i]);
		} catch (e) {
			bugsnag.notify(new Error("Invalid group discount id"), {
				data: data
			});
			continue;
		}

		this.discounts.push(id);
	}
}

scheme.methods.print = function (printer, data) {
	var self = this;
	
	var table = self.table.name;
	var employee = data.employee;
	
	const kChars = printer.characters;
	
	var datetime = common.getDatetime(kChars, new Date());
	
	var orderedString = "";
	
	var categories = [];
	var items = [];

	var postcode = "";
	if (self.postcode && self.postcode.length > 0) {
		postcode += " Address: " + self.postcode + "\n";
		postcode += " Distance: "+ self.postcodeDistance + "\n";
	}
	var deliveryTime = "";
	if (self.deliveryTime && self.deliveryTime.length > 0) {
		if (data.table.takeaway) {
			deliveryTime += " Takeaway Time: ";
		} else {
			deliveryTime += " Delivery Time: ";
		}

		deliveryTime += self.deliveryTime + "\n";
	}
	var customerName = "";
	if (self.customerName && self.customerName.length > 0) {
		customerName = " Customer: " + self.customerName + "\n";
	}
	var telephone = "";
	if (self.telephone && self.telephone.length > 0) {
		telephone = " Telephone: " + self.telephone + "\n";
	}

	for (var i = 0; i < self.orders.length; i++) {
		var order = self.orders[i];

		for (var x = 0; x < order.items.length; x++) {
			var item = order.items[x];

			if (typeof items[item.item._id] === 'undefined') {
				items[item.item._id] = item;
			} else {
				var it = items[item.item._id];
				it.quantity += item.quantity;
			}

			categories.push(item.item.category._id)
		}
	}

	// Convert items to a regular array
	var _items = [];
	for (var it in items) {
		if (items.hasOwnProperty(it)) {
			_items.push(items[it]);
		}
	}
	items = _items;
	_items = null;

	var tableId = data.table._id;
	// Fool the order object with a custom context (this)
	var ctx = {
		items: items
	}
	var order = new Order();
	var orderData = order.getOrderData.bind(ctx)(printer, {
		force: true,
		prices: true,
		notes: false
	});

	orderedString += orderData.data;

	var totalString = "";
	var total = "";
	total = " "+(Math.round(data.total * 100) / 100).toFixed(2)+" GBP\n";
	
	if (data.discounts.length > 0) {
		totalString = "\nSubtotal:"+common.getSpaces(kChars - 9 - total.length)+total;

		var discountValue = 0;
		for (var discount in data.discounts) {
			if (discount == 'length' || !data.discounts.hasOwnProperty(discount)) {
				continue;
			}

			discountValue += data.discounts[discount].value;

			var d = data.discounts[discount].name;
			var value = '-'+(Math.round(data.discounts[discount].value * 100) / 100).toFixed(2) + " GBP\n";
			totalString += d + common.getSpaces(kChars - d.length - value.length) + value;
		}

		total = " "+ (Math.round((data.total - discountValue) * 100) / 100).toFixed(2) + " GBP\n";
		totalString += "Total:"+common.getSpaces(kChars - 6 - total.length)+total+"\n";
	} else {
		totalString = "\nTotal:"+common.getSpaces(kChars - 6 - total.length)+total+"\n";
	}

	var servicedBy = "Serviced By " + employee;
	servicedBy = common.getSpaces(Math.floor((kChars - servicedBy.length)/2)) + servicedBy;

	var output = "\
Order #" + data.orderNumber + "\n\
" + table +"\n\n\
" + datetime + "\
" + servicedBy + "\n\n\
" + orderedString + "\
" + totalString + "\
" + postcode + "\
" + deliveryTime + "\
" + customerName + "\
" + telephone + "\
\n";
	
	winston.info(output);

	if (data.do_not_print === true) {
		// Just return the string..
		return output;
	}
	
	printer.socket.emit('print_data', {
		data: output,
		address: true,
		logo: true,
		footer: true
	});

	if (data.bar_copy === true) {
		var length = kChars;
		var half = Math.floor(length / 2);
		half -= Math.floor('Bar Copy'.length / 2);
		half -= 1;

		var pre = "\n";
		pre += common.getSpaces(length, '=')+"\n";
		pre += common.getSpaces(half, '=')+" ";
		pre += "Bar Copy";
		pre += " "+common.getSpaces(half, '=')+"\n";
		pre += common.getSpaces(length, '=')+"\n\n";

		output = pre + output + pre;

		winston.info(output);

		printer.socket.emit('print_data', {
			data: output,
			address: false,
			logo: false,
			footer: false
		});
	}
}

module.exports = mongoose.model("OrderGroup", scheme);