var mongoose = require('mongoose')
	, models = require('../models')
	, async = require('async')

exports.router = function (socket) {
	socket.on('get.group active', function(data) {
		var table = mongoose.Types.ObjectId(data.table);
		
		console.log("Getting an active group")
		
		models.OrderGroup.findOne({
			table: table,
			cleared: false
		}).populate('orders')
		.exec(function(err, order) {
			if (err) {
				throw err;
				return;
			}
			
			if (!order) {
				console.log("Creating a group for an empty table")
				order = new models.OrderGroup({
					table: table,
					cleared: false
				});
				order.save()
			}
			
			socket.emit('get.group active', [order])
		})
	})
	
	socket.on('save.group', function(data) {
		
	})
	socket.on('save.order', function(data) {
		
	})
	
	socket.on('add.order item', function(data) {
		
	})
}
