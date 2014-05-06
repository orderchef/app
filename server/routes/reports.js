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
		}).populate('orders').exec(function(err, order) {
			if (err) throw err;

			socket.emit('get.reports', {
				type: "order",
				order: order
			})
		});
	});

	socket.on('get.report sales data', function(data) {
		var from, to;

		from = new Date(data.from * 1000);
		to = new Date(data.to * 1000);

		models.OrderGroup.find({
			cleared: true,
			clearedAt: {
				$gte: from,
				$lt: to
			}
		}).select('orders table created cleared clearedAt orderNumber discounts orderTotal'
		).populate({
			path: 'table',
			select: 'delivery takeaway',
			options: {
				lean: true
			}
		}).exec(function(err, orderGroups) {
			if (err) throw err;

			async.each(orderGroups, function(orderGroup, cb) {
				orderGroup.updateTotal(cb);
			}, function() {
				var totals = {
					lunchtime: {
						delivery: 0,
						takeaway: 0,
						other: 0,
						total: 0
					},
					evening: {
						delivery: 0,
						takeaway: 0,
						other: 0,
						total: 0
					},
					total: {
						delivery: 0,
						takeaway: 0,
						other: 0,
						total: 0
					}
				};

				for (var i = 0; i < orderGroups.length; i++) {
					var orderGroup = orderGroups[i];

					var total = null;
					if (orderGroup.clearedAt.getHours() < 18 && orderGroup.clearedAt.getMinutes() < 31) {
						// Lunchtime
						total = totals.lunchtime;
					} else {
						// Evening
						total = totals.evening;
					}

					var t = orderGroup.orderTotal;
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

					total.total += t;
					totals.total.total += t;
				}

				socket.emit('get.reports', {
					type: 'salesData',
					totals: totals
				});
			});
		})
	});

	socket.on('get.report popular dishes', function(data) {
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
