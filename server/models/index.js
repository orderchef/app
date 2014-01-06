module.exports = {
	Table: require('./Table'),
	Item: require('./Item'),
	Category: require('./Category'),
	Employee: require('./Employee'),
	Report: require('./Report'),
	Order: require('./Order'),
	OrderGroup: require('./OrderGroup'),
	printers: []
}

if (process.env.NODE_ENV != 'production') {
	module.exports.printers.push({
		socket: { emit: function() {} },
		name: "Virtual Printer",
		ip: "127.0.0.1",
		printsBill: true,
		prices: true,
		characters: 40 //31
	})
}