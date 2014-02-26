var mongoose = require('mongoose')
	, schema = mongoose.Schema
	, ObjectId = schema.ObjectId;

var scheme = schema({
	name: { type: String, required: true },
	discountPercent: { type: Boolean, default: true },
	value: { type: Number, default: 0 },
	created: { type: Date, default: Date.now },
	allTables: { type: Boolean, default: false },
	allCategories: { type: Boolean, default: false },
	tables: [{
		type: ObjectId,
		ref: 'Table'
	}],
	categories: [{
		type: ObjectId,
		ref: 'Category'
	}],
	disabled: { type: Boolean, default: false }
});

// Discount may have Percentage (+-)
// Discount may have Value (+- in GBP)
// Discount may not have both Percentage and Value.

// Discount applies to many categories (eg food).
// Discount applies to only tables listed which also have orders with items whose categories match list here
// Alternatively, the discount can apply to all tables, but only categories listed
// Or to all Categories, but only tables listed
// Or to all categories and all tables (global discount)

scheme.methods.update = function (data) {
	this.name = data.name;
	this.value = date.value;
	this.allTables = data.allTables;
	this.allCategories = data.allCategories;
	this.tables = [];
	for (var i = 0; i < data.tables.length; i++) {
		this.tables.push(mongoose.Types.ObjectId(data.tables[i]));
	}
	this.categories = [];
	for (var i = 0; i < data.categories.length; i++) {
		this.categories.push(mongoose.Types.ObjectId(data.categories[i]));
	}
}

scheme.methods.applyValue = function (value) {
	if (this.discountPercent) {
		// -20 value = -20 % off
		var val = (this.value / 100) * -1;
		value *= 1 - val;
	} else {
		// usually -4 (£4 off). X +- 4 = x - 4
		value += this.value;
	}
	
	return value;
}

scheme.methods.applyDiscount = function (item, value) {
	if (this.allCategories == true) {
		return this.applyValue(value);
	}
	
	for (var i = 0; i < this.categories.length; i++) {
		if (item.item.category._id.equals(this.categories[i])) {
			return this.applyValue(value);
		}
	}
	
	return value;
}

scheme.statics.getDiscounts = function (table, order, callback) {
	var categories = [];
	
	for (var i = 0; i < order.items.length; i++) {
		categories.push(order.items[i].item.category._id)
	}
	
	module.exports.find({
		$and: [
			{
				$or: [
					{
						allTables: true
					},
					{
						tables: {
							$in: [table]
						}
					}
				],
			},
			{
				$or: [
					{
						allCategories: true
					},
					{
						categories: {
							$in: categories
						}
					}
				]
			}
		]
	}, function(err, discounts) {
		if (err) throw err;
		
		console.log(discounts)
		callback(discounts)
	})
}

module.exports = mongoose.model("Discount", scheme);

/*
new module.exports({
	name: "My Discount",
	discountPercent: true,
	value: -20,
	allTables: true,
	allCategories: true,
	tables: [],
	categories: []
}).save()
*/