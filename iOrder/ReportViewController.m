//
//  ReportViewController.m
//  iOrder
//
//  Created by Matej Kramny on 20/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "ReportViewController.h"
#import "ReportItemsViewController.h"
#import "OrdersViewController.h"
#import "Connection.h"
#import "AppDelegate.h"
#import "OrdersViewController.h"
#import "OrderGroup.h"
#import "Table.h"

@interface ReportViewController () {
	NSArray *orders;
	OrderGroup *group;
}

@end

@implementation ReportViewController

@synthesize dateRange;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	orders = @[];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:kReportsNotificationName object:nil];
	
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(refreshEvents:) forControlEvents:UIControlEventValueChanged];
	
	[self.navigationItem setTitle:@"Date Range"];
	
	[self refreshEvents:nil];
}

- (void)dealloc {
	@try {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:kReportsNotificationName object:nil];
	} @catch (NSException *exception) {}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"viewOrder"]) {
		OrdersViewController *ovc = (OrdersViewController *)[segue destinationViewController];
		
		//ovc.table = group.table;
		ovc.group = group;
	}
}

- (void)refreshEvents:(id)sender {
	[self.refreshControl beginRefreshing];
	[[[Connection getConnection] socket] sendEvent:@"get.reports" withData:
	 @{
	   @"from": [NSNumber numberWithInt:(int)[[dateRange objectAtIndex:0] timeIntervalSince1970]],
	   @"to": [NSNumber numberWithInt:(int)[[dateRange objectAtIndex:1] timeIntervalSince1970]]
	   }];
}

- (void)didReceiveNotification:(NSNotification *)notification {
	NSDictionary *reportData = [notification userInfo];
	NSString *type = [reportData objectForKey:@"type"];
	
	if ([type isEqualToString:@"orders"]) {
		orders = [reportData objectForKey:@"orders"];
		[self.refreshControl endRefreshing];
		[self.tableView reloadData];
	} else if ([type isEqualToString:@"order"]) {
		group = [[OrderGroup alloc] init];
		[group loadFromJSON:[reportData objectForKey:@"order"]];
		
		[self performSegueWithIdentifier:@"viewOrder" sender:group];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [orders count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detail" forIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	NSDictionary *order = [orders objectAtIndex:indexPath.row];
	cell.textLabel.text = [NSString stringWithFormat:@"Order #%d", [[order objectForKey:@"orderNumber"] intValue]];
	cell.detailTextLabel.text = [order objectForKey:@"clearedAt"];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[[Connection getConnection].socket sendEvent:@"get.report orderGroup" withData:@{
																					 @"_id": [[orders objectAtIndex:indexPath.row] objectForKey:@"_id"]
																					 }];
}

@end
