var mongoose = require('mongoose')
	, schema = mongoose.Schema
	, ObjectId = schema.ObjectId;

var scheme = schema({
	name: { type: String, required: true },
	discountPercent: { type: Boolean, default: true },
	value: { type: Number, default: 0 },
	created: { type: Date, default: Date.now },
	allCategories: { type: Boolean, default: false },
	categories: [{
		type: ObjectId,
		ref: 'Category'
	}],
	order: {
		type: Boolean,
		default: false
	},
	disabled: { type: Boolean, default: false }
});

// Discount may have Percentage (+-)
// Discount may have Value (+- in GBP)
// Discount may not have both Percentage and Value.

// Discount applies to many categories (eg food).
// Discount applies to only orders which select the discount, but is selected to items which have category (listed)

scheme.methods.update = function (data) {
	console.log(data);
	this.name = data.name;
	this.value = data.value;
	this.allCategories = data.allCategories;
	this.discountPercent = data.discountPercent;
	this.order = data.order;
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
	if (this.order == true || this.allCategories == true) {
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
		$or: [
			{
				allCategories: true
			},
			{
				order: true
			},
			{
				categories: {
					$in: categories
				}
			}
		],
		disabled: false
	}, function(err, discounts) {
		if (err) throw err;
		
		callback(discounts)
	})
}

module.exports = mongoose.model("Discount", scheme);