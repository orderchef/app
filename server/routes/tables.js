var mongoose = require('mongoose')
	, models = require('../models')
	, async = require('async')

exports.router = function (socket) {
	socket.on('get.tables', function(data) {
		console.log("Listing Tables")
		
		models.Table.find({
			deleted: false
		}, function(err, tables) {
			if (err) throw err;
			
			console.log(tables);
			socket.emit('get.tables', tables)
		})
	})
	
	socket.on('save.table', function(data) {
		console.log("Saving table ")
		
		models.Table.findById(data._id, function(err, table) {
			if (table) {
				table.update(data);
			} else {
				table = new models.Table({
					name: data.name
				});
			}
			
			table.save();
		});
	})
	
	socket.on('remove.table', function(data) {
		console.log("Deleting a table")
		
		var table = mongoose.Types.ObjectId(data.table);
		
		models.Table.findById(table, function(err, table) {
			if (err) throw err;
			
			table.deleted = true;
			table.save();
		})
	})
}