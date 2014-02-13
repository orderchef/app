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
			
			winston.info(tables);
			socket.emit('get.tables', tables)
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