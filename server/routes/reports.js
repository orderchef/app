var mongoose = require('mongoose')
	, models = require('../models')
	, spawn = require('child_process').spawn

exports.router = function (socket) {
	socket.on('get.reports', function(data) {
		console.log("Listing Reports")
		
		models.Report.find({}).sort('-created').exec(function(err, reports) {
			if (err) throw err;
			
			var rs = [];
			for (var i = 0; i < reports.length; i++) {
				var r = reports[i];
				rs.push({
					created: r.created.getTime() / 1000,
					delivery: r.delivery,
					takeaway: r.takeaway,
					
					name: r.name,
					notes: r.notes,
					
					items: r.items,
					
					total: r.total,
					quantity: r.quantity
				})
			}
			
			console.log(rs);
			socket.emit('get.reports', rs)
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
