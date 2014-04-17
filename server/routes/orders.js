var mongoose = require('mongoose')
	, models = require('../models')
	, async = require('async')
	, winston = require('winston')

exports.router = function (socket) {
	socket.on('get.group active', function(data) {
		winston.info("Getting an active group")
	
		var query = {
			cleared: false
		}
	
		if (data._id) {
			query._id = mongoose.Types.ObjectId(data._id);
		} else {
			query.table = mongoose.Types.ObjectId(data.table);
		}
	
		models.OrderGroup.find(query).populate('orders')
		.exec(function(err, orders) {
			if (err) {
				throw err;
				return;
			}
		
			if (!orders || orders.length == 0) {
				winston.info("Creating a group for an empty table")
				order = new models.OrderGroup({
					table: query.table,
					cleared: false
				});

				models.OrderGroup.findOne({}).select('orderNumber').sort('-orderNumber').limit(1).exec(function(err, lastOrder) {
					if (err) throw err;

					var orderNumber = lastOrder.orderNumber;
					models.OrderGroup.update({
						_id: order._id
					}, {
						$set: {
							orderNumber: orderNumber + 1
						}
					}, function(err) {
						if (err) throw err;
					});
				});

				order.save();
			
				orders.push(order)
			}
		
			socket.emit('get.group active', orders);
		})
	})
	
	socket.on('save.group', function(data) {
		winston.info("Saving group")
		
		models.OrderGroup.findById(data._id, function(err, group) {
			if (!group) {
				group = new models.OrderGroup();
			}
			
			group.update(data);
			group.save();
		})
	})
	
	socket.on('clear.group', function(data) {
		winston.info("Clearing orders from group")
		
		var group = mongoose.Types.ObjectId(data.group);
		
		models.OrderGroup.findById(group, function(err, group) {
			group.cleared = true;
			group.clearedAt = Date.now();
			group.save();
		})
	});
	
	socket.on('save.order', function(data, fn) {
		winston.info("Saving order")
		
		if (!data._id || data._id.length == 0) {
			order = new models.Order({
				created: Date.now()
			});
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
		winston.info("Adding item to order");
		
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
				models.Item.findById(item, function(err, item) {
					models.Discount.getDiscounts(mongoose.Types.ObjectId(data.tableid), [item.category], function(discounts) {
						var price = item.price;
						
						var ds = []
						for (var i = 0; i < discounts.length; i++) {
							var newPrice = discounts[i].applyDiscount(item.category, price);
							ds.push({
								name: discounts[i].name,
								discount: discounts[i]._id,
								value: price - newPrice
							})
							
							price = newPrice;
						}
						
						found = {
							item: item,
							notes: "",
							quantity: 1,
							price: price,
							discounts: ds
						}
						order.items.push(found)
						
						order.save();
					});
				})
				
				return;
			} else {
				found.quantity++;
			}
			
			order.save();
		})
		
		fn()
	})
	
	socket.on('remove.order item', function(data, fn) {
		winston.info("Removing item from order");
		
		models.Order.findById(data.order, function(err, order) {
			if (!order) {
				return;
			}
			
			var item = mongoose.Types.ObjectId(data.item);
			
			var found = false;
			for (var i = 0; i < order.items.length; i++) {
				var it = order.items[i];
				if (it.item.equals(item)) {
					order.items.splice(i, 1);
					break;
				}
			}
			
			order.save();
		})
	})
	
	socket.on('remove.order', function(data) {
		winston.info("Removing order");
		
		var group = mongoose.Types.ObjectId(data.group);
		var orderID = mongoose.Types.ObjectId(data.order);
		
		models.OrderGroup.findById(group).exec(function(err, order) {
			if (err || !order) {
				return;
			}
			
			for (var i = 0; i < order.orders.length; i++) {
				if (order.orders[i].equals(orderID)) {
					order.orders.splice(i, 1);
					models.Order.find({ _id: orderID }).remove(function(err) {
						if (err) throw err;
					});
				}
			}
			
			order.save()
		});
	})
	
	socket.on('print.group', function(data) {
		// Prints the final bill to receipt printer
		winston.info("Printing group bill");
		
		var group = mongoose.Types.ObjectId(data.group);
		
		models.OrderGroup.findById(group).populate('orders table').exec(function(err, group) {
			
			data.orderNumber = group.orderNumber;
			
			async.each(group.orders, function(order, cb) {
				order.populate('items.item', function() {
					async.each(order.items, function(item, cb) {
						item.item.populate('category', cb);
					}, cb);
				})
			}, function(err) {
				if (err) throw err;
				
				for (var i = 0; i < models.printers.length; i++) {
					if (!models.printers[i].printsBill) continue;
				
					winston.info("Printing bill to "+models.printers[i].name);
					group.print(models.printers[i], data)
				}
			})
		})
	})
	
	socket.on('print.order', function(data) {
		// Prints order to kitchens --except for receipt printer
		winston.info("Printing order ;)")
		
		var order = mongoose.Types.ObjectId(data.order);
		data.orderNumber = 0;

		models.OrderGroup.findOne({
			orders: {
				$in: [ order ]
			}
		}).select('orderNumber cookingTime telephone customerName').exec(function(err, ordergroup) {
			if (err) throw err;

			if (!ordergroup) {
				return;
			}

			data.orderNumber = ordergroup.orderNumber;
			data.cookingTime = ordergroup.cookingTime;
			data.telephone = ordergroup.telephone;
			data.customerName = ordergroup.customerName;

			models.Order.findById(order).populate('items.item').exec(function(err, order) {
				if (err || !order) {
					return;
				}
				
				order.printed = true;
				order.printedAt = Date.now();
				order.save();
				
				async.each(order.items, function(item, cb) {
					item.item.populate('category', cb)
				}, function(err) {
					if (err) throw err;
					
					for (var i = 0; i < models.printers.length; i++) {
						winston.info("Printing to "+models.printers[i].name)
						
						order.print(models.printers[i], data);
					}
				});
			});

		})
	})
}
