var mongoose = require('mongoose')
	, models = require('../models')
	, spawn = require('child_process').spawn
	, async = require('async')
	, winston = require('winston')

exports.router = function (socket) {
	socket.on('get.reports', function(data) {
		winston.info("Listing Reports")
		
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
