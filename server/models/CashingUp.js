var mongoose = require('mongoose')
	, schema = mongoose.Schema
	, ObjectId = schema.ObjectId;

var scheme = schema({
	voucher: Number,
	cash: Number,
	card: Number,
	pettyCash: Number,
	labour: Number,
	tips: Number,
	created: { type: Date, default: Date.now }
});

scheme.methods.update = function (data) {
	this.voucher = data.voucher;
	this.cash = data.cash;
	this.card = data.card;
	this.pettyCash = data.pettyCash;
	this.labour = data.labour;
	this.tips = data.tips;
	
	if (data.created) {
		this.created = data.created;
	}
}

module.exports = mongoose.model("CashingUp", scheme);