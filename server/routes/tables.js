var mongoose = require('mongoose')
	, models = require('../models')
	, async = require('async')
	, winston = require('winston')

exports.router = function (socket) {
	socket.on('get.tables', function(data) {
		winston.info("Listing Tables")
		
		models.Table.find({
			deleted: false
		}, function(err, tables) {
			if (err) throw err;
			
			var _tables = [];
			for (var i = 0; i < tables.length; i++) {
				_tables.push(tables[i].toObject());
			}
			tables = _tables;

			async.each(tables, function(table, cb) {
				models.OrderGroup.findOne({
					table: table._id,
					cleared: false
				}).select('orders customerName').exec(function(err, ordergroup) {
					if (err) throw err;
					
					if (ordergroup) {
						table.orders = ordergroup.orders.length;
						table.customerName = ordergroup.customerName;
					}

					cb(null);
				})
			}, function() {
				socket.emit('get.tables', tables)
			})
		})
	})
	
	socket.on('save.table', function(data) {
		winston.info("Saving table ")
		
		models.Table.findById(data._id, function(err, table) {
			if (!table) {
				table = new models.Table();
			}
			
			table.update(data);
			
			table.save();
		});
	})
	
	socket.on('remove.table', function(data) {
		winston.info("Deleting a table")
		
		var table = mongoose.Types.ObjectId(data.table);
		
		models.Table.findById(table, function(err, table) {
			if (err) throw err;
			
			table.deleted = true;
			table.save();
		})
	})
}