var mongoose = require('mongoose')
	, models = require('../models')
	, spawn = require('child_process').spawn

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
		
		models.Table.findById(table, function(err, table) {
			if (err) throw err;
			
			table.items = [];
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
		
		models.Table.findById(table).populate('items.item').exec(function(err, table) {
			if (err) throw err;
			
			var d = new Date()
			var date = "" + d.getHours() + ":" + d.getMinutes() + "hrs and " + d.getSeconds() + " seconds"
			var orderedString = "";
			
			for (var i = 0; i < table.items.length; i++) {
				orderedString += " -- "+table.items[i].quantity+" x "+table.items[i].item.name+"\n";
			}
			
			var output = "--------------------\n\
New Order for Table: -"+ table.name +"\n\
Time of order:\n" + date + "\n\n\
Ordered Items:\n" + orderedString;
			
			var proc = spawn('python', ['print.py']);
			proc.stdout.on('data', function (data) {
				console.log("Out ~>")
				console.log(data.toString());
			})
			proc.stderr.on('data', function(data) {
				console.log("Err ~>")
				console.log(data.toString());
			})
			proc.stdin.write(output, 'utf-8');
			proc.stdin.end();
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
}