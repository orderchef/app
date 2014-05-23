var mongoose = require('mongoose')
	, schema = mongoose.Schema
	, ObjectId = schema.ObjectId;

var scheme = schema({
	voucher: {
		type: Number,
		default: 0
	},
	cash: {
		type: Number,
		default: 0
	},
	card: {
		type: Number,
		default: 0
	},
	pettyCash: {
		type: Number,
		default: 0
	},
	labour: {
		type: Number,
		default: 0
	},
	tips: {
		type: Number,
		default: 0
	},
	created: { type: Date, default: Date.now }
});

scheme.methods.update = function (data) {
	this.voucher = data.voucher;
	this.cash = data.cash;
	this.card = data.card;
	this.pettyCash = data.pettyCash;
	this.labour = data.labour;
	this.tips = data.tips;

	if (!this.voucher) this.voucher = 0;
	if (!this.cash) this.cash = 0;
	if (!this.card) this.card = 0;
	if (!this.pettyCash) this.pettyCash = 0;
	if (!this.labour) this.labour = 0;
	if (!this.tips) this.tips = 0;
	
	if (data.created) {
		this.created = new Date(data.created * 1000);
	}
}

module.exports = mongoose.model("CashingUp", scheme);