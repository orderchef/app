var mongoose = require('mongoose')
	, models = require('../models')
	, spawn = require('child_process').spawn
	, async = require('async')
	, winston = require('winston')
	, credentials = require('../credentials')

exports.router = function (socket) {
	socket.on('get.reports', function(data) {
		var from, to;

		from = new Date(data.from * 1000);
		to = new Date(data.to * 1000);

		models.OrderGroup.find({
			cleared: true,
			clearedAt: {
				$gte: from,
				$lt: to
			}
		}).sort('-clearedAt')
		.lean()
		.select('orderNumber clearedAt table')
		.populate({
			path: 'table',
			select: 'delivery takeaway name',
			options: {
				lean: true
			}
		})
		.exec(function(err, orders) {
			if (err) throw err;

			var os = [];
			for (var i = 0; i < orders.length; i++) {
				var o = orders[i];
				o.clearedAt = Math.floor(new Date(o.clearedAt).getTime() / 1000);
				os.push(o);
			}

			socket.emit('get.reports', {
				orders: os,
				type: "orders",
				from: data.from,
				to: data.to
			})
		})
	});

	socket.on('get.report orderGroup', function(data) {
		models.OrderGroup.findOne({
			_id: data._id
		})
		.lean()
		.populate({
			path: 'orders',
			options: {
				lean: true
			}
		})
		.exec(function(err, order) {
			if (err) throw err;

			for (var x = 0; x < order.printouts.length; x++) {
				var t = order.printouts[x].time;
				order.printouts[x].time = t.getDate() + "/" + t.getMonth() + "/" + t.getFullYear() + " " + t.getHours() + ":" + t.getMinutes() + ":" + t.getSeconds();
			}

			socket.emit('get.reports', {
				type: "order",
				order: order
			})
		});
	});

	socket.on('get.report sales data', function(data) {
		console.log("Getting sales data");

		var from, to;

		from = new Date(data.from * 1000);
		to = new Date(data.to * 1000);

		models.OrderGroup.find({
			cleared: true,
			clearedAt: {
				$gte: from,
				$lt: to
			}
		})
		.lean()
		.select('table created cleared clearedAt orderNumber discountTotal orderTotal')
		.populate({
			path: 'table',
			select: 'delivery takeaway',
			options: {
				lean: true
			}
		})
		.exec(function(err, orderGroups) {
			if (err) throw err;

			var totals = {
				lunchtime: {
					delivery: 0,
					takeaway: 0,
					other: 0,
					discount: 0,
					total: 0
				},
				evening: {
					delivery: 0,
					takeaway: 0,
					other: 0,
					discount: 0,
					total: 0
				},
				total: {
					delivery: 0,
					takeaway: 0,
					other: 0,
					discount: 0,
					total: 0
				}
			};

			for (var i = 0; i < orderGroups.length; i++) {
				var orderGroup = orderGroups[i];

				var total = null;
				if (orderGroup.clearedAt.getHours() > 17 || (orderGroup.clearedAt.getHours() == 17 && orderGroup.clearedAt.getMinutes() > 30)) {
					// Evening
					total = totals.evening;
				} else {
					// Lunchtime
					total = totals.lunchtime;
				}

				var t = orderGroup.orderTotal - orderGroup.discountTotal;
				if (isNaN(t)) continue;

				var key = '';
				if (orderGroup.table.delivery) {
					key = 'delivery';
				} else if (orderGroup.table.takeaway) {
					key = 'takeaway';
				} else {
					key = 'other';
				}

				if (key.length > 0) {
					total[key] += t;
					totals.total[key] += t;
				}

				total.discount += orderGroup.discountTotal;
				totals.total.discount += orderGroup.discountTotal;

				total.total += t;
				totals.total.total += t;
			}

			socket.emit('get.reports', {
				type: 'salesData',
				totals: totals
			});
		})
	});

	socket.on('get.report popular dishes', function(data) {
		console.log("Report Popular Dishes")
		// heavy op.
		if (!credentials.do_heavy_reports) {
			// Not doing this!
			return;
		}

		var from, to;

		from = new Date(data.from * 1000);
		to = new Date(data.to * 1000);

		models.OrderGroup.find({
			cleared: true,
			clearedAt: {
				$gte: from,
				$lt: to
			}
		})
		.populate({
			path: 'orders',
			options: {
				lean: true
			}
		})
		.lean()
		.exec(function(err, ordergroups) {
			if (err) throw err;

			var items = {};
			var items_length = 0;

			for (var i = 0; i < ordergroups.length; i++) {
				var group = ordergroups[i];
				for (var oi = 0; oi < group.orders.length; oi++) {
					var order = group.orders[oi];
					for (var ii = 0; ii < order.items.length; ii++) {
						var item = order.items[ii];

						if (typeof items[item.item] !== 'object') {
							items[item.item] = {
								quantity: 0,
								price: item.price,
								total: 0,
								_id: item.item
							}
							items_length++;
						}

						items[item.item].quantity += item.quantity;
						items[item.item].total += item.quantity * item.price;
					}
				}
			}

			var _items = [];
			for (var item in items) {
				if (!items.hasOwnProperty(item)) {
					continue;
				}

				_items.push(items[item]);
			}
			items = null;

			async.each(_items, function(item, cb) {
				models.Item.findOne({
					_id: item._id
				}).lean().exec(function(err, item_item) {
					item.item = item_item;
					
					cb(err);
				})
			}, function(err) {
				if (err) throw err;

				// Order by best selling

				_items.sort(function(a,b) {
					if (a.total < b.total) return 1;
					if (a.total > b.total) return -1;
					return 0;
				});
				var quantity = JSON.parse(JSON.stringify(_items));
				quantity.sort(function(a,b) {
					if (a.quantity < b.quantity) return 1;
					if (a.quantity > b.quantity) return -1;
					return 0;
				});

				socket.emit('get.reports', {
					type: 'popularDishes',
					price: _items,
					quantity: quantity
				});
			});
		})
	})
}
