var mongoose = require('mongoose')
	, models = require('../models')
	, spawn = require('child_process').spawn

exports.router = function (socket) {
	socket.on('get.categories', function(data) {
		console.log("Listing categories")
		
		models.Category.find({}, function(err, cats) {
			if (err) throw err;
			
			console.log(cats);
			socket.emit('get.categories', cats)
		})
	});
	
	socket.on('create.category', function(data) {
		console.log("Creating category ")
		console.log(data);
		var category = new models.Category(data);
		category.save();
	})
}
