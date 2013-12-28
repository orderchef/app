var mongoose = require('mongoose')
	, models = require('../models')
	, spawn = require('child_process').spawn
	, async = require('async')

exports.router = function (socket) {
	socket.on('get.reports', function(data) {
		console.log("Listing Reports")
		
		models.OrderGroup.find({
			cleared: true
		}).sort('-clearedAt').populate('orders table').exec(function(err, groups) {
			if (err) throw err;
			
			//console.log(groups);
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
	
	socket.on('print.report', function(data) {
		console.log("Printing Report");
		
		models.Report.findById(data._id, function(err, report) {
			if (err || !report) {
				return;
			}
			
			var output = "--------------------\n\
Report for Date: "+ report.created.getDate() +"/" + (report.created.getMonth()+1) + "/" +report.created.getFullYear() + "\n\
Items Ordered: " + report.quantity + "\n\
Total Paid: £" + report.total + "\n\
--------------------\n";
			console.log(output);
			
			for (var i = 0; i < models.printers.length; i++) {
				models.printers[i].socket.emit('print_data', {
					data: output
				});
			}
		})
	})
}
