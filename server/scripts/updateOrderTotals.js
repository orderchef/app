var app = require('../app')
	, mongoose = require('mongoose')
	, models = require('../models')
	, async = require('async')
	, winston = require('winston')
	, bugsnag = require('bugsnag')

var number = 0;
models.OrderGroup.find({
	cleared: true
}).select('_id').exec(function(err, groups) {
	async.eachSeries(groups, function(group, callback) {
		var data = {};

		models.OrderGroup
		.findById(group._id)
		.populate({
			path: 'discounts',
			options: {
				lean: true
			}
		}).populate('orders table')
		.exec(function(err, group) {
			data.orderNumber = group.orderNumber;
			data.table = group.table;
			
			async.each(group.orders, function(order, cb) {
				order.populate('items.item', function() {
					async.each(order.items, function(item, cb) {
						item.item.populate('category', cb);
					}, cb);
				})
			}, function(err) {
				if (err) throw err;

				// Apply Discounts
				var total = 0;
				var discountsValue = 0;
				var discounts = {
					length: 0
				};
				// _id: {name: string, value: 23.99}

				for (var i = 0; i < group.orders.length; i++) {
					var o = group.orders[i];
					for (var i_item = 0; i_item < o.items.length; i_item++) {
						var item = o.items[i_item];

						var price = item.price * item.quantity;
						total += price;

						if (!(item.item && item.item.category && item.item.category._id)) {
							continue;
						}

						for (var i_discount = 0; i_discount < group.discounts.length; i_discount++) {
							var discount = group.discounts[i_discount];

							if (typeof discounts[discount._id] !== 'object') {
								discounts[discount._id] = {
									name: '',
									value: 0
								};
								discounts.length++;
							}

							discounts[discount._id].name = discount.name;
							if (discount.discountPercent) {
								discounts[discount._id].name += ' (-' + (Math.round(discount.value * 100) / 100).toFixed(2) + '%)';
							} else {
								discounts[discount._id].name += ' (-' + (Math.round(discount.value * 100) / 100) + ' GBP)';
							}

							var new_price = discount.applyDiscount(item.item.category._id, price);

							var discountValue = price - new_price;
							discounts[discount._id].value += discountValue;
							discountsValue += discountValue;
						}
					}
				}

				data.total = total;
				data.discounts = discounts;
				
				group.orderTotal = total;
				group.discountTotal = discountsValue;
				group.save();

				console.log("Done!", number++);
				callback();
			})
		})
	})
})