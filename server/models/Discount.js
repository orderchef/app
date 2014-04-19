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
	this.value = data.value;
	this.allTables = data.allTables;
	this.allCategories = data.allCategories;
	this.discountPercent = data.discountPercent;
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
		// 20 value = -20 % off
		value *= 1 - (this.value / 100);
	} else {
		value -= this.value;
	}
	
	return value;
}

scheme.methods.applyDiscount = function (category, value) {
	if (this.allCategories == true) {
		return this.applyValue(value);
	}
	
	for (var i = 0; i < this.categories.length; i++) {
		if (category.equals(this.categories[i])) {
			return this.applyValue(value);
		}
	}
	
	return value;
}

scheme.statics.getDiscounts = function (table, categories, callback) {
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
		],
		disabled: false
	}, function(err, discounts) {
		if (err) throw err;
		
		callback(discounts)
	})
}

module.exports = mongoose.model("Discount", scheme);