var moment = require('moment')

exports.getSpaces = function (spaces) {
	var spacer = "";
	while (spaces >= 0) {
		spacer += " ";
		spaces--;
	}
	
	return spacer;
}

exports.getDatetime = function (kChars, d) {
	var datetime = moment(d).format('dddd Do MMM, YYYY [at] hh:mma');
	
	return exports.getSpaces(Math.floor((kChars - datetime.length + 1)/2)) + datetime + "\n";
}
