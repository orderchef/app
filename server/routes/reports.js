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
		}).sort('-orderNumber').select('orderNumber clearedAt').exec(function(err, orders) {
			if (err) throw err;

			var os = [];
			for (var i = 0; i < orders.length; i++) {
				var o = orders[i].toObject();
				var clearedAt = o.clearedAt;

				var hrs = clearedAt.getHours();
				var mins = clearedAt.getMinutes();
				if (hrs < 10) hrs = "0"+hrs;
				if (mins < 10) mins = "0"+mins;

				o.clearedAt = clearedAt.getDate() + '/' + (clearedAt.getMonth()+1) + '/' + clearedAt.getFullYear() + ' ' + hrs + ':' + mins;
				os.push(o)
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
	})

	socket.on('get.reports_days', function(data) {
		winston.info("Listing Reports Days");

		return;
		
		models.OrderGroup.find({
			cleared: true
		}).sort('-clearedAt').populate('orders table').exec(function(err, groups) {
			if (err) throw err;
			
			async.each(groups, function(group, cb) {
				async.each(group.orders, function(order, cb) {
					order.populate('items.item', function(err) {
						async.each(order.items, function(item, cb) {
							item.item.populate('category', cb)
						}, cb);
					});
				}, cb);
			}, function(err) {
				if (err) throw err;
				
				// Aggregate reports
				models.OrderGroup.aggregate(socket, groups);
			});
		})
	});
}
