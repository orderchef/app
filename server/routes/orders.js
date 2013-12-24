var mongoose = require('mongoose')
	, models = require('../models')
	, async = require('async')

exports.router = function (socket) {
	socket.on('get.group active', function() {
		var table = mongoose.Types.ObjectId(data.table);
		
		models.OrderGroup.findOne({
			table: table,
			cleared: false
		}).populate('orders')
		.exec(function(err, order) {
			if (err || !order) {
				return;
			}
			
			socket.emit('get.ordergroup active', order)
		})
	})
	
	socket.on('add.ordergroup order', function() {
		// add a new order
	})
}
