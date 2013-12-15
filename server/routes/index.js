var mongoose = require('mongoose')
	, models = require('../models')
	, spawn = require('child_process').spawn

var categories = require('./categories')
	, items = require('./items')
	, staff = require('./staff')
	, tables = require('./tables')
	, reports = require('./reports')

exports.router = function (socket) {
	categories.router(socket);
	items.router(socket);
	staff.router(socket);
	tables.router(socket);
	reports.router(socket);
}
