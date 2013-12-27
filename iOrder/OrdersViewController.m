//
//  OrdersViewController.m
//  OrderChef
//
//  Created by Matej Kramny on 27/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "OrdersViewController.h"
#import "Table.h"
#import "Item.h"
#import "MenuViewController.h"
#import "OrderItemViewController.h"
#import "TextareaCell.h"
#import "Employee.h"
#import "AppDelegate.h"
#import "OrderGroup.h"
#import "Order.h"
#import "OrderViewController.h"

@interface OrdersViewController ()

@end

@implementation OrdersViewController

@synthesize table;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.navigationItem.title = table.name;
	
	[self setRefreshControl:[[UIRefreshControl alloc] init]];
    [self.refreshControl addTarget:self action:@selector(refreshOrders:) forControlEvents:UIControlEventValueChanged];
    
	[self refreshOrders:nil];
    [self reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"order"]) {
		OrderViewController *vc = (OrderViewController *)[segue destinationViewController];
		vc.order = (Order *)sender;
		vc.table = table;
		vc.navigationItem.title = [NSString stringWithFormat:@"Order #%d", (int)[self.tableView indexPathForSelectedRow].row+1];
	}
}

- (void)reloadData {
	[self.tableView reloadData];
}

- (void)refreshOrders:(id)sender {
	[self.table loadItems];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.tableView reloadData];
	[table addObserver:self forKeyPath:@"group" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
    @try {
        [table removeObserver:self forKeyPath:@"group" context:nil];
    }
    @catch (NSException *exception) {}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"group"]) {
		[self reloadData];
        if ([self.refreshControl isRefreshing])
            [self.refreshControl endRefreshing];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
		return [table.group orders].count;
	}
	
	if (section == 1) {
		return 1;
	}
	
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"basket";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	if (indexPath.section == 0) {
		Order *o = [table.group.orders objectAtIndex:indexPath.row];
		cell.textLabel.text = [NSString stringWithFormat:@"#%d", ((int)indexPath.row)+1];
		float total = 0;
		int totalq = 0;
		for (NSDictionary *item in o.items) {
			int q = [[item objectForKey:@"quantity"] intValue];
			float p = [[(Item *)[item objectForKey:@"item"] price] floatValue];
			total += q * p;
			totalq += q;
		}
		
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%d items, £%.2f", totalq, total];
	} else {
		cell.textLabel.text = @"Create New Order";
		cell.detailTextLabel.text = nil;
	}
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Order *o;
	if (indexPath.section == 1) {
		o = [[Order alloc] init];
		o.group = table.group;
		[o save];
		
		NSMutableArray *orders = [table.group.orders mutableCopy];
		[orders addObject:o];
		table.group.orders = orders;
		
		[table.group setOrders:orders];
	} else {
		o = [table.group.orders objectAtIndex:indexPath.row];
	}
	
	[self performSegueWithIdentifier:@"order" sender:o];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Orders";
	}
	
	return nil;
}

@end
