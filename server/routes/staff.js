var mongoose = require('mongoose')
	, models = require('../models')
	, spawn = require('child_process').spawn
	, winston = require('winston')

exports.router = function (socket) {
	socket.on('get.staff', function(data) {
		winston.info("Listing Staff")
		
		models.Employee.find({}).sort('-manager').exec(function(err, staff) {
			if (err) throw err;
			
			socket.emit('get.staff', staff)
		})
	});
	
	socket.on('save.employee', function(data) {
		winston.info("Saving an Employee")
		
		models.Employee.findById(data._id, function(err, employee) {
			if (!employee) {
				employee = new models.Employee();
			}
			
			employee.update(data);
			
			employee.save();
		});
	})
	
	socket.on('remove.employee', function(data) {
		winston.info("Removing an Employee!")
		
		models.Employee.findById(data._id, function(err, employee) {
			if (err || !employee) {
				return;
			}
			
			employee.remove();
		})
	});
}