var io = require('socket.io').listen(8080);
var mongoose = require('mongoose')
	, models = require('./models')

mongoose.connect("mongodb://127.0.0.1/iorder", {
	auto_reconnect: true,
	native_parser: true
})

io.sockets.on('connection', function(socket) {
	console.log("Socket connected..");
	
	socket.on('get.items', function(data) {
		console.log("Listing Items")
		
		models.Item.find({}, function(err, items) {
			if (err) throw err;
			
			console.log(items);
			socket.emit('get.items', items)
		})
	});
	socket.on('get.items table', function(data) {
		console.log("Listing Items for Table")
		
		var table = mongoose.Types.ObjectId(data.table);
		
		models.Table.findById(table).populate('items.item').exec(function(err, table) {
			socket.emit('get.items table', {
				table: table._id,
				items: table.items
			})
		})
	})
	socket.on('get.tables', function(data) {
		console.log("Listing Tables")
		
		models.Table.find({}, function(err, tables) {
			if (err) throw err;
			
			console.log(tables);
			socket.emit('get.tables', tables)
		})
	});
	socket.on('get.categories', function(data) {
		console.log("Listing categories")
		
		models.Category.find({}, function(err, cats) {
			if (err) throw err;
			
			console.log(cats);
			socket.emit('get.categories', cats)
		})
	});
	
	socket.on('create.item', function(data) {
		console.log("Creating item ")
		console.log(data);
		try {
			data.category = mongoose.Types.ObjectId(data.category)
		} catch (e) {
			data.category = null;
		} finally {
			var item = new models.Item(data)
			item.save();
		}
	})
	socket.on('create.table', function(data) {
		console.log("Creating table ")
		console.log(data);
		var table = new models.Table(data);
		table.save();
	})
	socket.on('create.category', function(data) {
		console.log("Creating category ")
		console.log(data);
		var category = new models.Category(data);
		category.save();
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
	socket.on('set.item category', function(data) {
		console.log("Setting category to item");
		
		var itemID = mongoose.Types.ObjectId(data.item);
		var categoryID = mongoose.Types.ObjectId(data.category);
		
		models.Item.findById(itemID, function(err, item) {
			item.category = categoryID;
			item.save();
		})
	})
})