require('../app')
var models = require('../models')
var async = require('async')

models.OrderGroup.find({
	cleared: false,
	orderNumber_locked: false
}).sort('-created').select('orderNumber orderNumber_generated orderNumber_locked').exec(function(err, orders) {
	var orderNumber = 1;

	if (orders.length == 0) {
		console.log("nothing to do")
		process.exit(0);
	}

	async.each(orders, function(order, callback) {
		order.orderNumber = orderNumber++;
		order.orderNumber_generated = Date.now();

		console.log("Saved ", order);

		order.save(callback);
	}, function(err) {
		if (err) throw err;

		console.log("Done");
		process.exit(0);
	});
});