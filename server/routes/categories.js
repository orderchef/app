var mongoose = require('mongoose')
	, models = require('../models')
	, spawn = require('child_process').spawn
	, winston = require('winston')

exports.router = function (socket) {
	socket.on('get.categories', function(data) {
		winston.info("Listing categories")
		
		models.Category.find({
			deleted: false
		}).sort('name').exec(function(err, cats) {
			if (err) throw err;
			
			socket.emit('get.categories', cats)
		})
	});
	
	socket.on('save.category', function(data) {
		winston.info("Saving category ")
		
		models.Category.findById(data._id, function(err, category) {
			if (err || !category) {
				category = new models.Category();
			}
			
			category.update(data);
			category.save();
		});
	})
	
	socket.on('remove.category', function(data) {
		winston.info("Removing category");
		
		models.Category.findById(data._id, function(err, category) {
			if (err || !category) {
				return;
			}
			
			category.deleted = true;
			category.save()
		})
	})
}
