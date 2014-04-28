//
//  ReportsViewController.m
//  iOrder
//
//  Created by Matej Kramny on 15/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "ReportsViewController.h"
#import "Storage.h"
#import "Connection.h"
#import "AppDelegate.h"
#import "ReportViewController.h"
#import "AppDelegate.h"

@interface ReportsViewController ()

@end

@implementation ReportsViewController

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"basic";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	switch (indexPath.row) {
		case 0:
			cell.textLabel.text = @"View Orders";
			break;
		case 1:
			cell.textLabel.text = @"Sales Report";
			break;
		case 2:
			cell.textLabel.text = @"Graphs";
			break;
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *destination;
	
	if (indexPath.row == 0) {
		destination = @"reportOrders";
	} else {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		return;
	}
	
	[self performSegueWithIdentifier:destination sender:nil];
}

@end
