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
		socket: {},
		name: "",
		ip: "",
		prices: false,
		category: ""
	})
}