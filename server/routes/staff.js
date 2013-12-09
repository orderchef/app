var mongoose = require('mongoose')
	, models = require('../models')
	, spawn = require('child_process').spawn

exports.router = function (socket) {
	socket.on('get.staff', function(data) {
		console.log("Listing Staff")
		
		models.Staff.find({}).sort('-manager').exec(function(err, staff) {
			if (err) throw err;
			
			console.log(staff);
			socket.emit('get.staff', staff)
		})
	});
	
	socket.on('create.staff', function(data) {
		console.log("Creating Staff ")
		console.log(data);
		
		models.Staff.findById(data._id, function(err, staff) {
			if (staff) {
				staff.update(data);
			} else {
				staff = new models.Staff({
					name: data.name,
					code: data.code,
					manager: data.manager
				});
			}
			
			staff.save();
		});
	})
}