var mongoose = require('mongoose')
	, models = require('../models')
	, spawn = require('child_process').spawn

exports.router = function (socket) {
	socket.on('get.staff', function(data) {
		console.log("Listing Staff")
		
		models.Employee.find({}).sort('-manager').exec(function(err, staff) {
			if (err) throw err;
			
			console.log(staff);
			socket.emit('get.staff', staff)
		})
	});
	
	socket.on('save.employee', function(data) {
		console.log("Saving an Employee")
		
		models.Employee.findById(data._id, function(err, employee) {
			if (!employee) {
				employee = new models.Employee();
			}
			
			employee.update(data);
			
			employee.save();
		});
	})
	
	socket.on('remove.employee', function(data) {
		console.log("Removing an Employee!")
		
		models.Employee.findById(data._id, function(err, employee) {
			if (err || !employee) {
				return;
			}
			
			employee.remove();
		})
	});
}