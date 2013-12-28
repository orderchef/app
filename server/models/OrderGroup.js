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
	
	socket.emit('get.reports', finalData)
}

module.exports = mongoose.model("OrderGroup", scheme);