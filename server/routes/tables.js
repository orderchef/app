var mongoose = require('mongoose')
	, models = require('../models')
	, async = require('async')

function getSpaces (spaces) {
	var spacer = "";
	while (spaces >= 0) {
		spacer += " ";
		spaces--;
	}
	
	return spacer;
}

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
			var r = models.Report.addOrder(table);
			r.save()
	
			table.resetTable()
			table.save();
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
			
			var d = new Date()
			var date = "Time of Order:";
			var date2 = d.getHours() + ":" + d.getMinutes() + "\n";
			date = date + getSpaces(31 - date.length - date2.length) + date2;
			var orderedString = "";
			
			var total = 0;
			for (var i = 0; i < table.items.length; i++) {
				var it = table.items[i];
				var val = it.quantity * it.item.price;
				
				var valueString = " (GBP) " + val.toFixed(2) + "\n";
				var string = it.quantity+" "+it.item.name+" ";
				
				var spaces = 31 - valueString.length - string.length;
				orderedString += string + getSpaces(spaces) + valueString;
				
				total += it.quantity * it.item.price;
			}
			
			var tableName = "Table "+ table.name;
			var tableLength = 31 - tableName.length;
			var spaces = getSpaces(Math.floor((tableLength+1)/2))
			tableName = spaces + tableName;
			
			var total = " (GBP) "+total.toFixed(2)+"\n";
			var output = "\
" + tableName +"\n\n\
" + date + "\
Notes: " + table.notes + "\n\n\
Ordered Items:\n" + orderedString + "\n\n\
Total:"+getSpaces(31 - 6 - total.length)+total+"\n\
\n\n";
			console.log(output);
			
			for (var i = 0; i < models.printers.length; i++) {
				models.printers[i].socket.emit('print_data', {
					data: output
				});
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