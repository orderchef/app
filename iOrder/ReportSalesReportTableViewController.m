//
//  ReportSalesReportTableViewController.m
//  OrderChef
//
//  Created by Matej Kramny on 05/05/2014.
//  Copyright (c) 2014 Matej Kramny. All rights reserved.
//

#import "ReportSalesReportTableViewController.h"
#import "AppDelegate.h"
#import "Connection.h"

@interface ReportSalesReportTableViewController () {
	NSArray *sales; // many of NSDictionarys
	NSDictionary *salesReport;
}

@end

@implementation ReportSalesReportTableViewController

@synthesize dateRange;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:kReportsNotificationName object:nil];
	
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(refreshEvents:) forControlEvents:UIControlEventValueChanged];
	
	[self.navigationItem setTitle:@"Sales Report"];
	
	[self refreshEvents:nil];
}

- (void)dealloc {
	@try {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:kReportsNotificationName object:nil];
	} @catch (NSException *exception) {}
}

- (void)refreshEvents:(id)sender {
	[self.refreshControl beginRefreshing];
	[[[Connection getConnection] socket] sendEvent:@"get.report sales data" withData:
	 @{
	   @"from": [NSNumber numberWithInt:(int)[[dateRange objectAtIndex:0] timeIntervalSince1970]],
	   @"to": [NSNumber numberWithInt:(int)[[dateRange objectAtIndex:1] timeIntervalSince1970]]
	   }];
}

- (void)didReceiveNotification:(NSNotification *)notification {
	NSDictionary *reportData = [notification userInfo];
	NSString *type = [reportData objectForKey:@"type"];
	
	if ([type isEqualToString:@"salesData"]) {
		salesReport = [reportData objectForKey:@"totals"];
		
		[self.refreshControl endRefreshing];
		[self.tableView reloadData];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detail" forIndexPath:indexPath];
	
	NSDictionary *data;
	
	if (indexPath.section == 0) {
		data = [salesReport objectForKey:@"total"];
	} else if (indexPath.section == 1) {
		data = [salesReport objectForKey:@"lunchtime"];
	} else if (indexPath.section == 2) {
		data = [salesReport objectForKey:@"evening"];
	}
	
	if (indexPath.row == 0) {
		// Delivery
		cell.textLabel.text = @"Delivery Tables";
		cell.detailTextLabel.text = [NSString stringWithFormat:@"£%.2f", [[data objectForKey:@"delivery"] floatValue]];
	} else if (indexPath.row == 1) {
		cell.textLabel.text = @"Takeaway Tables";
		cell.detailTextLabel.text = [NSString stringWithFormat:@"£%.2f", [[data objectForKey:@"takeaway"] floatValue]];
	} else if (indexPath.row == 2) {
		cell.textLabel.text = @"All Tables";
		cell.detailTextLabel.text = [NSString stringWithFormat:@"£%.2f", [[data objectForKey:@"total"] floatValue]];
	}
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"Grand Total";
		case 1:
			return @"Lunchtime";
		case 2:
			return @"Evening";
		default:
			return nil;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 0) {
		return @"Lunchtime + Evening Sales";
	}
	if (section == 1) {
		return @"Orders made between 00:00 - 17:30";
	}
	if (section == 2) {
		return @"Orders made between 17:30 - 24:00";
	}
	
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
