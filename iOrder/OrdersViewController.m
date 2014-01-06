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
    
	UIBarButtonItem *printItem = [[UIBarButtonItem alloc] initWithTitle:@"\uf02f " style:UIBarButtonItemStylePlain target:self action:@selector(printOrder:)];
	[printItem setTitleTextAttributes:@{
										NSFontAttributeName: [UIFont fontWithName:@"FontAwesome" size:24]
										} forState:UIControlStateNormal];
    [self.navigationItem setRightBarButtonItem:printItem animated:YES];
	
	[self refreshOrders:nil];
    [self reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"order"]) {
		OrderViewController *vc = (OrderViewController *)[segue destinationViewController];
		vc.order = (Order *)sender;
		vc.table = table;
		
		NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
		int row = (int)selectedIndexPath.row+1;
		if (selectedIndexPath.section == 1) {
			row = table.group.orders.count;
		}
		
		vc.navigationItem.title = [NSString stringWithFormat:@"Order #%d", row];
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

- (void)printOrder:(id)sender {
	[table.group printBill];
	[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:@"Final Bill Printed" detail:nil hideAfter:0.5 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:self.navigationController.view];
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
		return 2;
	}
	
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"basket";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.textAlignment = NSTextAlignmentLeft;
	if (indexPath.section == 0) {
		cell.textLabel.font = [UIFont fontWithName:@"FontAwesome" size:18.f];
		
		Order *o = [table.group.orders objectAtIndex:indexPath.row];
		NSString *checkmark = @"\uf096\t";
		if (o.printed) {
			checkmark = @"\uf046\t";
		}
		cell.textLabel.text = [NSString stringWithFormat:@"%@#%d", checkmark, ((int)indexPath.row)+1];
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
		if (indexPath.row == 0) {
			cell.textLabel.text = @"Create New Order";
		} else {
			cell.textLabel.text = @"Print Final Bill";
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.textLabel.textAlignment = NSTextAlignmentCenter;
		}
		cell.detailTextLabel.text = nil;
	}
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Order *o;
	if (indexPath.section == 1) {
		if (indexPath.row == 1) {
			// clear
			[table.group clear];
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:@"Orders Cleared" detail:nil hideAfter:0.5 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:self.view];
			[self refreshOrders:nil];
			return;
		}
		
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

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 1) {
		return @"Final Bill will print to the Printer by the Counter. Button above will also mark this order as finalised, and will be available in the reports.";
	}
	
	return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0)
		return YES;
	
	return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section != 0 || editingStyle != UITableViewCellEditingStyleDelete) {
		return;
	}
	
	Order *order = [table.group.orders objectAtIndex:indexPath.row];
	[order remove];
	
	NSMutableArray *mutableOrders = [table.group.orders mutableCopy];
	[mutableOrders removeObjectAtIndex:indexPath.row];
	[table.group setOrders:[mutableOrders copy]];
	
	[self reloadData];
}

@end
