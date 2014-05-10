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
	
	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"\uf02f " style:UIBarButtonItemStylePlain target:self action:@selector(printReport:)]];
	[self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{
																	NSFontAttributeName: [UIFont fontWithName:@"FontAwesome" size:24]
																	} forState:UIControlStateNormal];
	
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

- (void)printReport:(id) sender {
	__block NSMutableString *report = [[NSMutableString alloc] init];
	
	void (^getString)(NSDictionary *) = ^(NSDictionary *data) {
		[report appendString:@"Delivery Tables: "];
		[report appendFormat:@"%.2f (GBP)\n", [[data objectForKey:@"delivery"] floatValue]];
		[report appendString:@"Takeaway Tables: "];
		[report appendFormat:@"%.2f (GBP)\n", [[data objectForKey:@"takeaway"] floatValue]];
		[report appendString:@"Eat In Tables: "];
		[report appendFormat:@"%.2f (GBP)\n", [[data objectForKey:@"other"] floatValue]];
		[report appendString:@"All Tables: "];
		[report appendFormat:@"%.2f (GBP)\n\n", [[data objectForKey:@"total"] floatValue]];
	};
	
	[report appendString:@"Total:\n"];
	getString([salesReport objectForKey:@"total"]);
	[report appendString:@"Lunchtime (00:00-17:30):\n"];
	getString([salesReport objectForKey:@"lunchtime"]);
	[report appendString:@"Evening (17:30-24:00):\n"];
	getString([salesReport objectForKey:@"evening"]);
	
	[[Connection getConnection].socket sendEvent:@"print" withData:@{
																	 @"data": report,
																	 @"receiptPrinter": [NSNumber numberWithBool:true],
																	 @"printDate": [NSNumber numberWithBool:true]
																	 }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 4;
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
		cell.textLabel.text = @"Eat In Tables";
		cell.detailTextLabel.text = [NSString stringWithFormat:@"£%.2f", [[data objectForKey:@"other"] floatValue]];
	} else if (indexPath.row == 3) {
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
