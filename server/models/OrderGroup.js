var mongoose = require('mongoose')
	, schema = mongoose.Schema
	, ObjectId = schema.ObjectId
	, async = require('async')
	, common = require('../common')
	, moment = require('moment')
	, winston = require('winston')
	, Discount = require('./Discount')
	, Order = require('./Order')

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
	postcode: String,
	postcodeDistance: String,
	deliveryTime: String,
	cookingTime: String,
	telephone: String,
	customerName: String
})

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
		this.orders.push(mongoose.Types.ObjectId(data.orders[i]));
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
		deliveryTime = " Delivery Time: " + self.deliveryTime + "\n";
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

	var tableId = mongoose.Types.ObjectId(data.tableid);
	Discount.getDiscounts(tableId, categories, function(discounts) {
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
		total = " "+orderData.total.toFixed(2)+" GBP\n";
		totalString = "\nTotal:"+common.getSpaces(kChars - 6 - total.length)+total+"\n";
	
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
		
		printer.socket.emit('print_data', {
			data: output,
			address: true,
			logo: true,
			footer: true
		});
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