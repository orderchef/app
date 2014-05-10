var moment = require('moment')

exports.getSpaces = function (spaces, character) {
	var spacer = "";
	if (typeof character === 'undefined') {
		character = " ";
	}
	
	while (spaces > 0) {
		spacer += character;
		spaces--;
	}
	
	return spacer;
}

exports.getDatetime = function (kChars, d) {
	var datetime = moment(d).format('ddd DD/MM/YY HH:mm');
	
	return exports.getSpaces(Math.floor((kChars - datetime.length + 1)/2)) + datetime + "\n";
}
