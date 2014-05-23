module.exports = {
	Table: require('./Table'),
	Item: require('./Item'),
	Category: require('./Category'),
	Employee: require('./Employee'),
	Report: require('./Report'),
	Order: require('./Order'),
	OrderGroup: require('./OrderGroup'),
	Discount: require('./Discount'),
	CashingUp: require('./CashingUp'),
	printers: []
}

if (process.env.NODE_ENV != 'production') {
	module.exports.printers.push({
		socket: { emit: function() {} },
		name: "Virtual Receipt Printer",
		ip: "127.0.0.1",
		printsBill: true, // makes it a receipt printer
		prices: true,
		characters: 40 //31
	})
	module.exports.printers.push({
		socket: { emit: function() {} },
		name: "Virtual Kitchen Printer",
		ip: "127.0.0.1",
		printsBill: false, // makes it a receipt printer
		prices: false,
		characters: 40 //31
	})
}