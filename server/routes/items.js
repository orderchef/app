var mongoose = require('mongoose')
	, models = require('../models')
	, spawn = require('child_process').spawn

exports.router = function (socket) {
	socket.on('get.items', function(data) {
		console.log("Listing Items")
		
		models.Item.find({
			disabled: false
		}, function(err, items) {
			if (err) throw err;
			
			console.log(items);
			socket.emit('get.items', items)
		})
	});
	
	socket.on('set.item category', function(data) {
		console.log("Setting category to item");
		
		var itemID = mongoose.Types.ObjectId(data.item);
		var categoryID = mongoose.Types.ObjectId(data.category);
		
		models.Item.findById(itemID, function(err, item) {
			item.category = categoryID;
			item.save();
		})
	})
	
	socket.on('save.item', function(data) {
		console.log("Saving item ")
		
		models.Item.findById(data._id, function(err, item) {
			try {
				data.category = mongoose.Types.ObjectId(data.category)
			} catch (e) {
				data.category = null;
			} finally {
				if (err || !item) {
					item = new models.Item();
				}
				
				item.update(data);
				item.save();
			}
		});
	})
	
	socket.on('delete.item', function(data) {
		console.log("Deleting item");
		
		models.Item.findById(data._id, function(err, item) {
			if (err || !item) {
				return;
			}
			
			item.disabled = true;
			item.save();
		})
	})
}
