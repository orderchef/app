//
//  ReportCashingUpViewController.m
//  OrderChef
//
//  Created by Matej Kramny on 21/05/2014.
//  Copyright (c) 2014 Matej Kramny. All rights reserved.
//

#import "ReportCashingUpViewController.h"
#import "AppDelegate.h"
#import "Connection.h"

@interface ReportCashingUpViewController () {
	NSArray *prices; // many of NSDictionarys
	NSArray *quantity;
	NSDictionary *salesReport;
}

@end

@implementation ReportCashingUpViewController

@synthesize dateRange;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:kReportsNotificationName object:nil];
	
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(refreshEvents:) forControlEvents:UIControlEventValueChanged];
	
	[self.navigationItem setTitle:@"Popular Dishes"];
	
	[self refreshEvents:nil];
}

- (void)dealloc {
	@try {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:kReportsNotificationName object:nil];
	} @catch (NSException *exception) {}
}

- (void)refreshEvents:(id)sender {
	[self.refreshControl beginRefreshing];
	[[[Connection getConnection] socket] sendEvent:@"get.report cashingUp" withData:
	 @{
	   @"from": [NSNumber numberWithInt:(int)[[dateRange objectAtIndex:0] timeIntervalSince1970]],
	   @"to": [NSNumber numberWithInt:(int)[[dateRange objectAtIndex:1] timeIntervalSince1970]]
	   }];
}

- (void)didReceiveNotification:(NSNotification *)notification {
	NSDictionary *reportData = [notification userInfo];
	NSString *type = [reportData objectForKey:@"type"];
	
	if ([type isEqualToString:@"cashingUp"]) {
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
	if (section == 0) return 1;
	if (section == 1) return 7;
	if (section == 2) return 0;
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detail" forIndexPath:indexPath];
	
	if (indexPath.section == 0) {
		cell.textLabel.text = @"Add Cashup";
		cell.textLabel.textAlignment = NSTextAlignmentCenter;
	} else if (indexPath.section == 1) {
		cell.textLabel.text = @"";
		cell.detailTextLabel.text = @"£0";
	}
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 1:
			return @"By Sales (Quantity sold)";
		default:
			return nil;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 0) {
		[self performSegueWithIdentifier:@"openCashup" sender:nil];
		return;
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
