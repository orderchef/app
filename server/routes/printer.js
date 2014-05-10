var mongoose = require('mongoose')
	, models = require('../models')
	, spawn = require('child_process').spawn
	, winston = require('winston')

exports.router = function (socket) {
	socket.on('register', function(data) {
		//winston.info(models.printers);
		
		winston.info("Registering a printer @"+data.ip + " called "+data.name);

		socket.set('printer', data.name, function(err) {
			if (err) throw err;

			console.log("Socket marked.");

			var now = new Date;
			var date = now.getDate() + "/" + (now.getMonth()+1) + "/" + now.getFullYear() + " " + now.getHours() + ":" + now.getMinutes();
			var string = "\n"+
"Date: " + date + "\n"+
"Printer connected: " + data.name + "\n"+
"The system _might_ have restarted, this is just to let you know that all printers are connected to the system. You may throw this receipt in the bin."+
"If all printers aren't connected, call Matej on 07955522239.";

			print({
				receiptPrinter: true,
				data: string
			});
		});

		socket.on('disconnect', function() {
			console.log("Dat motherfucker disconnected!");

			var now = new Date;
			var date = now.getDate() + "/" + (now.getMonth()+1) + "/" + now.getFullYear() + " " + now.getHours() + ":" + now.getMinutes();
			print({
				receiptPrinter: true,
				data: "\n"+
"=========================\n"+
"= PRINTER DISCONNECTED! =\n"+
"=========================\n"+
"\n"+
"Date: "+date+"\n"+
"Printer: "+data.name+"\n"+
"The printer named above has disconnected! Please wait 2 minutes, you will get a receipt that the printer is connected. If not, call Matej on 07955522239.\n"+
"Possible reasons why it has disconnected:\n"+
"- Pi isn't connected\n"+
"- The Printer is disconnected (cable) from the Pi\n"+
"- The Pi lost network connection\n"+
"- The printer has no paper\n"
});
		})
		
		var printer = {
			socket: socket,
			name: data.name,
			ip: data.ip,
			printsBill: data.printsBill, // makes it a receipt printer
			prices: data.prices,
			characters: data.characters //31
		}
		
		var found = false;
		for (var i = 0; i < models.printers.length; i++) {
			if (models.printers[i].name == printer.name) {
				models.printers[i] = printer;
				found = true;
				break;
			}
		}
		
		if (!found) {
			models.printers.push(printer)
		}
	})
	
	socket.on('get.printers', function(data, cb) {
		winston.info("Sending back printers..");
		
		var ps = [];
		for (var i = 0; i < models.printers.length; i++) {
			ps.push({
				name: models.printers[i].name,
				ip: models.printers[i].ip,
				prices: models.printers[i].prices,
				category: models.printers[i].category
			});
		}
		
		cb(ps);
	})
	
	socket.on('print', print);
}

// bool data.receiptPrinter
// string data.data
// bool data.printDate
function print (data) {
	winston.info("Printing some data..");
	
	if (data.printDate) {
		var now = new Date;
		var date = now.getDate() + "/" + (now.getMonth()+1) + "/" + now.getFullYear() + " " + now.getHours() + ":" + now.getMinutes();
		data.data = "\nDate: "+date+"\n"+data.data+"\n";
	}
	
	var receiptPrinterOnly = data.receiptPrinter;
	for (var i = 0; i < models.printers.length; i++) {
		if (models.printers[i].printsBill == receiptPrinterOnly) {
			winston.info("Printing to", models.printers[i].name);
			winston.info(data.data+"\n")
			models.printers[i].socket.emit('print_data', {
				data: data.data
			})
		}
	}
}