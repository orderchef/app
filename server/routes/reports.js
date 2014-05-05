var mongoose = require('mongoose')
	, models = require('../models')
	, spawn = require('child_process').spawn
	, async = require('async')
	, winston = require('winston')

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
						total: 0
					},
					evening: {
						delivery: 0,
						takeaway: 0,
						total: 0
					},
					total: {
						delivery: 0,
						takeaway: 0,
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

					if (orderGroup.table.delivery) {
						total.delivery += orderGroup.orderTotal;
						totals.total.delivery += orderGroup.orderTotal;
					} else if (orderGroup.table.takeaway) {
						total.takeaway += orderGroup.orderTotal;
						totals.total.takeaway += orderGroup.orderTotal;
					}

					total.total += orderGroup.orderTotal;
					totals.total.total += orderGroup.orderTotal;
				}

				console.log(totals);

				socket.emit('get.reports', {
					type: 'salesData',
					totals: totals
				});
			});
		})
	});
}
