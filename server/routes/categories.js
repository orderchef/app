var mongoose = require('mongoose')
	, models = require('../models')
	, spawn = require('child_process').spawn

exports.router = function (socket) {
	socket.on('get.categories', function(data) {
		console.log("Listing categories")
		
		models.Category.find({
			deleted: false
		}).sort('name').exec(function(err, cats) {
			if (err) throw err;
			
			console.log(cats);
			socket.emit('get.categories', cats)
		})
	});
	
	socket.on('create.category', function(data) {
		console.log("Creating category ")
		console.log(data);
		
		models.Category.findById(data._id, function(err, category) {
			if (err || !category) {
				category = new models.Category();
			}
			
			category.update(data);
			category.save();
		});
	})
	
	socket.on('remove.category', function(data) {
		console.log("Removing category");
		
		models.Category.findById(data._id, function(err, category) {
			if (err || !category) {
				return;
			}
			
			category.deleted = true;
			category.save()
		})
	})
}
