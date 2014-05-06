//
//  ReportPopularDishesTableViewController.m
//  OrderChef
//
//  Created by Matej Kramny on 06/05/2014.
//  Copyright (c) 2014 Matej Kramny. All rights reserved.
//

#import "ReportPopularDishesTableViewController.h"
#import "AppDelegate.h"
#import "Connection.h"

@interface ReportPopularDishesTableViewController () {
	NSArray *prices; // many of NSDictionarys
	NSArray *quantity;
	NSDictionary *salesReport;
}

@end

@implementation ReportPopularDishesTableViewController

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
	[[[Connection getConnection] socket] sendEvent:@"get.report popular dishes" withData:
	 @{
	   @"from": [NSNumber numberWithInt:(int)[[dateRange objectAtIndex:0] timeIntervalSince1970]],
	   @"to": [NSNumber numberWithInt:(int)[[dateRange objectAtIndex:1] timeIntervalSince1970]]
	   }];
}

- (void)didReceiveNotification:(NSNotification *)notification {
	NSDictionary *reportData = [notification userInfo];
	NSString *type = [reportData objectForKey:@"type"];
	
	if ([type isEqualToString:@"popularDishes"]) {
		prices = [reportData objectForKey:@"price"];
		quantity = [reportData objectForKey:@"quantity"];
		
		[self.refreshControl endRefreshing];
		[self.tableView reloadData];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return section == 0 ? [prices count] : [quantity count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detail" forIndexPath:indexPath];
	
	NSDictionary *data;
	NSString *format;
	
	if (indexPath.section == 0) {
		data = [prices objectAtIndex:indexPath.row];
		format = [NSString stringWithFormat:@"£%.2f", [[data objectForKey:@"total"] floatValue]];
	} else if (indexPath.section == 1) {
		data = [quantity objectAtIndex:indexPath.row];
		format = [NSString stringWithFormat:@"%d", [[data objectForKey:@"quantity"] intValue]];
	}
	
	cell.textLabel.text = [[data objectForKey:@"item"] objectForKey:@"name"];
	cell.detailTextLabel.text = format;
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"By Total Price";
		case 1:
			return @"By Sales (Quantity sold)";
		default:
			return nil;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
