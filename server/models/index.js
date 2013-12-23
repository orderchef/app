module.exports = {
	Table: require('./Table'),
	Item: require('./Item'),
	Category: require('./Category'),
	Staff: require('./Staff'),
	Report: require('./Report'),
	printers: [{
			socket: {},
			name: "",
			ip: "",
			prices: false,
			category: ""
		}]
}