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
				rs.push({
					created: reports[i].created.getTime() / 1000,
					tables: reports[i].tables,
					total: reports[i].total,
					quantity: reports[i].quantity,
					_id: reports[i]._id
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
			
			var proc = spawn('python', ['print.py']);
			proc.stdout.on('data', function (data) {
				console.log("Out ~>")
				console.log(data.toString());
			})
			proc.stderr.on('data', function(data) {
				console.log("Err ~>")
				console.log(data.toString());
			})
			proc.stdin.write(output, 'utf-8');
			proc.stdin.end();
		})
	})
}
