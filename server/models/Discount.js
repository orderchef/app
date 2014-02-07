var mongoose = require('mongoose')
	, schema = mongoose.Schema
	, ObjectId = schema.ObjectId;

var scheme = schema({
	name: { type: String, required: true },
	discountPercent: { type: Boolean, default: true },
	percent: { type: Number, default: 0 },
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
	}]
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
	this.percent = data.percent;
	this.value = date.value;
	this.allTables = data.allTables;
	this.allCategories = data.allCategories;
	this.tables = [];
	for (var i = 0; i < data.tables.length; i++) {
		this.tables.push(data.tables[i]);
	}
	this.categories = [];
	for (var i = 0; i < data.categories.length; i++) {
		this.categories.push(data.categories[i]);
	}
}

module.exports = mongoose.model("Discount", scheme);