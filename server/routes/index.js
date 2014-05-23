var mongoose = require('mongoose')
	, models = require('../models')
	, spawn = require('child_process').spawn

var routes = [];

routes.push(require('./categories'));
routes.push(require('./items'));
routes.push(require('./staff'));
routes.push(require('./tables'));
routes.push(require('./reports'));
routes.push(require('./printer'));
routes.push(require('./orders'));
routes.push(require('./discounts'));
routes.push(require('./cashingUp'));

exports.router = function (s) {
	for (i in routes) {
		routes[i].router(s)
	}
}
