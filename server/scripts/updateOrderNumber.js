require('../app')
var models = require('../models')
var async = require('async')

// WARNING: Resets all IDS to ascending

models.OrderGroup.find({
}).sort('-created').select('orderNumber').exec(function(err, orders) {
	var orderNumber = 1;

	for (var i = 0; i < orders.length; i++) {
		orders[i].orderNumber = orderNumber++;
		orders[i].save(function(err) {
			if (err) throw err;
		})
	}
})