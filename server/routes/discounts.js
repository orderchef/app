var mongoose = require('mongoose')
	, models = require('../models')
	, spawn = require('child_process').spawn
	, winston = require('winston')
	, bugsnag = require('bugsnag')

exports.router = function (socket) {
	socket.on('get.discounts', function(data) {
		winston.info("Listing Discounts")
		
		models.Discount.find({
			disabled: false
		}, function(err, discounts) {
			if (err) throw err;
			
			socket.emit('get.discounts', discounts)
		})
	});
	
	socket.on('save.discount', function(data) {
		winston.info("Saving Discount ")
		
		if (data.name.length == 0) return;
		
		models.Discount.findById(data._id, function(err, discount) {
			if (!discount) {
				discount = new models.Discount();
			}
			
			try {
				discount.update(data);
			} catch (e) {
				return bugsnag.notify(e)
			}
			
			discount.save();
		});
	})
	
	socket.on('remove.discount', function(data) {
		winston.info("Deleting Discount");
		
		var id = data._id;
		try {
			id = mongoose.Types.ObjectId(data._id)
		} catch (e) {
			winston.error(e);
			return;
		}
		
		models.Discount.findById(id, function(err, discount) {
			if (err || !discount) {
				return;
			}
			
			discount.disabled = true;
			discount.save();
		})
	})
}
