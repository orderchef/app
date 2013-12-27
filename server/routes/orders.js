var mongoose = require('mongoose')
	, models = require('../models')
	, async = require('async')

exports.router = function (socket) {
	socket.on('get.group active', function(data) {
		var table = mongoose.Types.ObjectId(data.table);
		
		console.log("Getting an active group")
		
		models.OrderGroup.findOne({
			table: table,
			cleared: false
		}).populate('orders')
		.exec(function(err, order) {
			if (err) {
				throw err;
				return;
			}
			
			if (!order) {
				console.log("Creating a group for an empty table")
				order = new models.OrderGroup({
					table: table,
					cleared: false
				});
				order.save()
			}
			
			socket.emit('get.group active', [order])
		})
	})
	
	socket.on('save.group', function(data) {
		console.log("Saving group")
		
		models.OrderGroup.findById(data._id, function(err, group) {
			if (!group) {
				group = new models.OrderGroup();
			}
			
			group.update(data);
			group.save();
		})
	})
	socket.on('save.order', function(data, fn) {
		console.log("Saving order")
		
		if (!data._id || data._id.length == 0) {
			order = new models.Order();
			order.update(data)
			order.save()
			
			fn(order._id);
			return;
		}
		
		models.Order.findById(data._id, function(err, order) {
			if (!order) {
				return;
			}
			
			order.update(data);
			order.save();
		})
	})
	
	socket.on('add.order item', function(data, fn) {
		console.log("Adding item to order");
		
		models.Order.findById(data.order, function(err, order) {
			if (!order) {
				return;
			}
			
			var item = mongoose.Types.ObjectId(data.item);
			
			var found = false;
			for (var i = 0; i < order.items.length; i++) {
				var it = order.items[i];
				if (it.item.equals(item)) {
					found = it;
					break;
				}
			}
			
			if (found === false) {
				found = {
					item: item,
					notes: "",
					quantity: 1
				}
				order.items.push(found)
			} else {
				found.quantity++;
			}
			
			order.save();
		})
	})
}
