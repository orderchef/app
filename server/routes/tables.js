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
	});
	socket.on('create.table', function(data) {
		console.log("Creating table ")
		console.log(data);
		
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
	
	socket.on('remove.table items', function(data) {
		console.log("Clearing Table")
		
		var table = mongoose.Types.ObjectId(data.table);
		
		models.Table.getTable(table, function(err, table) {
			for (var i = 0; i < models.printers.length; i++) {
				console.log(models.printers[i])
				table.printOrder(models.printers[i]);
			}
			
			table.printOrder()
			
			var r = models.Report.addOrder(table);
			r.save()
	
			//table.resetTable()
			//table.save();
		})
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
	socket.on('table.send kitchen', function(data) {
		console.log("Sending order to kitchen..")
		
		var table = mongoose.Types.ObjectId(data.table);
		
		models.Table.getTable(table, function(err, table) {
			if (err) throw err;
			
			for (var i = 0; i < models.printers.length; i++) {
				console.log(models.printers[i])
				table.printOrder(models.printers[i]);
			}
		})
	})
	socket.on('add.table item', function(data) {
		console.log("Adding Item to Table")
		
		var table = mongoose.Types.ObjectId(data.table);
		var itemID = mongoose.Types.ObjectId(data.item);
		
		models.Table.findById(table, function(err, table) {
			var found = false;
			var it = null;
			
			console.log(table.items)
			
			for (var i = 0; i < table.items.length; i++) {
				var item = table.items[i];
				console.log(item)
				
				if (item.item.equals(itemID)) {
					found = true;
					it = item;
					break;
				}
			}
			
			if (found) {
				it.quantity++;
			} else {
				it = {
					item: itemID,
					quantity: 1
				}
				table.items.push(it);
			}
			
			table.save();
		})
	})
	
	socket.on('remove.table item', function(data) {
		console.log("Removing Item from Table")
		
		var table = mongoose.Types.ObjectId(data.table);
		var itemID = mongoose.Types.ObjectId(data.item);
		
		models.Table.findById(table, function(err, table) {
			var found = false;
			var it = null;
			
			for (var i = 0; i < table.items.length; i++) {
				var item = table.items[i];
				
				if (item.item.equals(itemID)) {
					table.items.splice(i, 1);
					
					break;
				}
			}
			
			table.save();
		})
	})
}