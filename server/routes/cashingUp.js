var mongoose = require('mongoose')
	, models = require('../models')
	, spawn = require('child_process').spawn
	, winston = require('winston')

exports.router = function (socket) {
	socket.on('get.report cashing up', function(data) {
		winston.info("Doing Cashing Up")
		
		var from, to;

		from = new Date(data.from * 1000);
		to = new Date(data.to * 1000);

		models.CashingUp.find({
			created: {
				$gte: from,
				$lt: to
			}
		})
		.lean()
		.exec(function(err, cashups) {
			if (err) throw err;
			
			// aggregate the data
			var aggregate = {
				voucher: 0,
				cash: 0,
				card: 0,
				pettyCash: 0,
				labour: 0,
				tips: 0
			};

			for (var i = 0; i < cashups.length; i++) {
				var c = cashups[i];

				aggregate.voucher += c.voucher;
				aggregate.cash += c.cash;
				aggregate.card += c.card;
				aggregate.pettyCash += c.pettyCash;
				aggregate.labour += c.labour;
				aggregate.tips += c.tips;

				c.total = c.cash
						 + c.card
						 + c.pettyCash
						 + c.labour
						 + c.voucher;
				c.created = new Date(c.created).getTime() / 1000;
			}

			aggregate.gross = aggregate.cash
								 + aggregate.card
								 + aggregate.pettyCash
								 + aggregate.labour
								 + aggregate.voucher;

			socket.emit('get.reports', {
				type: 'cashingUp',
				cashups: cashups,
				aggregate: aggregate
			});
		})
	});
	
	socket.on('save.cashup', function(data) {
		winston.info("Saving Cashup Report")
		
		models.CashingUp.findById(data._id, function(err, cashup) {
			if (err || !cashup) {
				cashup = new models.CashingUp();
			}
			
			cashup.update(data);
			cashup.save();
		});
	})
	
	socket.on('remove.cashup', function(data) {
		winston.info("Removing Cashup Report");
		
		models.CashingUp.findById(data._id, function(err, cashup) {
			if (err || !cashup) {
				return;
			}
			
			cashup.deleted = true;
			cashup.save()
		})
	})
}
