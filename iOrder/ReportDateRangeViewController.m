//
//  ReportViewController.m
//  iOrder
//
//  Created by Matej Kramny on 20/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "ReportDateRangeViewController.h"
#import "OrdersViewController.h"
#import "Connection.h"
#import "AppDelegate.h"
#import "OrdersViewController.h"
#import "OrderGroup.h"
#import "Table.h"

@interface ReportDateRangeViewController () {
	OrderGroup *group;
	NSMutableDictionary *sections;
}

@end

@implementation ReportDateRangeViewController

@synthesize dateRange;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	sections = [[NSMutableDictionary alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:kReportsNotificationName object:nil];
	
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(refreshEvents:) forControlEvents:UIControlEventValueChanged];
	
	[self.navigationItem setTitle:@"Past Orders"];
	
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
		[self parseOrders:[reportData objectForKey:@"orders"]];
		[self.refreshControl endRefreshing];
		[self.tableView reloadData];
	} else if ([type isEqualToString:@"order"]) {
		group = [[OrderGroup alloc] init];
		[group loadFromJSON:[reportData objectForKey:@"order"]];
		
		[self performSegueWithIdentifier:@"viewOrder" sender:group];
	}
}

- (void)parseOrders:(NSArray *)orders {
	sections = [[NSMutableDictionary alloc] init];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"dd/MM/yyyy"];
	
	for (NSDictionary *order in orders) {
		int timeInterval = [[order objectForKey:@"clearedAt"] intValue];
		NSDate *clearedAt = [NSDate dateWithTimeIntervalSince1970:timeInterval];
		bool delivery = [[[order objectForKey:@"table"] objectForKey:@"delivery"] boolValue];
		bool takeaway = [[[order objectForKey:@"table"] objectForKey:@"takeaway"] boolValue];
		
		NSString *addon = @"";
		if (delivery) {
			addon = @" - Delivery Tables";
		}
		if (takeaway) {
			addon = @" - Takeaway Tables";
		}
		
		NSString *dateString = [[formatter stringFromDate:clearedAt] stringByAppendingString:addon];
		
		if ([sections objectForKey:dateString] == nil) {
			[sections setObject:[[NSMutableArray alloc] init] forKey:dateString];
		}
		
		[(NSMutableArray *)[sections objectForKey:dateString] addObject:order];
	}
	
	for (NSString *key in [sections allKeys]) {
		NSMutableArray *arr = [sections objectForKey:key];
		[sections setObject:[[arr sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"orderNumber" ascending:NO]]] mutableCopy] forKey:key];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[sections allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [(NSMutableArray *)[sections objectForKey:[[sections allKeys] objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detail" forIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"'at' hh:mm"];
	
	NSDictionary *order = [(NSMutableArray *)[sections objectForKey:[[sections allKeys] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	cell.textLabel.text = [NSString stringWithFormat:@"#%d   [%@]", [[order objectForKey:@"orderNumber"] intValue], [[order objectForKey:@"table"] objectForKey:@"name"]];
	
	int timeInterval = [[order objectForKey:@"clearedAt"] intValue];
	NSDate *clearedAt = [NSDate dateWithTimeIntervalSince1970:timeInterval];
	
	cell.detailTextLabel.text = [formatter stringFromDate:clearedAt];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *order = [(NSMutableArray *)[sections objectForKey:[[sections allKeys] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	[[Connection getConnection].socket sendEvent:@"get.report orderGroup" withData:@{
																					 @"_id": [order objectForKey:@"_id"]
																					 }];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [[sections allKeys] objectAtIndex:section];
}

@end
