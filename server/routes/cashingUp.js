var mongoose = require('mongoose')
	, models = require('../models')
	, spawn = require('child_process').spawn
	, winston = require('winston')

exports.router = function (socket) {
	socket.on('get.report cashingUp', function(data) {
		winston.info("Doing Cashing Up")
		
		var from, to;

		from = new Date(data.from * 1000);
		to = new Date(data.to * 1000);

		models.CashingUp.find({
			created: {
				$gte: from,
				$lt: to
			}
		})
		.lean()
		.exec(function(err, cashups) {
			if (err) throw err;
			
			socket.emit('get.reports', {
				type: 'cashingUp',
				cashups: cashups
			});
		})
	});
	
	socket.on('save.cashup', function(data) {
		winston.info("Saving Cashup Report")
		
		models.CashingUp.findById(data._id, function(err, cashup) {
			if (err || !category) {
				cashup = new models.CashingUp();
			}
			
			cashup.update(data);
			cashup.save();
		});
	})
	
	socket.on('remove.cashup', function(data) {
		winston.info("Removing Cashup Report");
		
		models.CashingUp.findById(data._id, function(err, cashup) {
			if (err || !cashup) {
				return;
			}
			
			cashup.deleted = true;
			cashup.save()
		})
	})
}
