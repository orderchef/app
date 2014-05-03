//
//  DiscountsViewController.m
//  OrderChef
//
//  Created by Matej Kramny on 07/02/2014.
//  Copyright (c) 2014 Matej Kramny. All rights reserved.
//

#import "DiscountsViewController.h"
#import "AppDelegate.h"
#import "DiscountViewController.h"
#import "Connection.h"
#import "Discount.h"
#import "OrderGroup.h"

@interface DiscountsViewController () {
	NSArray *discounts;
	Discount *newDiscount;
}

@end

@implementation DiscountsViewController

@synthesize group;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.navigationItem setTitle:@"Discounts"];
	
	if (group) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			// Its in popover mode
			self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
			//self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.203f green:0.444f blue:0.768f alpha:1.f];
			//self.navigationController.navigationBar.alpha = 1.f;
			//self.navigationController.navigationBar.translucent = NO;
		} else {
			[self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeModal:)] animated:NO];
		}
	} else {
		[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addDiscount:)] animated:NO];
	}
	
	[self setRefreshControl:[[UIRefreshControl alloc] init]];
	[[self refreshControl] addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:kDiscountsNotificationName object:nil];
	[self refresh];
}

- (void)addDiscount:(id)sender {
	newDiscount = [[Discount alloc] init];
	[self performSegueWithIdentifier:@"openDiscount" sender:newDiscount];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"openDiscount"]) {
		DiscountViewController *vc = [segue destinationViewController];
		vc.discount = (Discount *)sender;
	}
}

- (void)closeModal:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveNotification:(NSNotification *)notification {
	if ([[notification name] isEqualToString:kDiscountsNotificationName]) {
		discounts = [[notification userInfo] objectForKey:@"discounts"];
		
		[self.tableView reloadData];
		[self.refreshControl endRefreshing];
	}
}

- (void)refresh {
	[[Connection getConnection].socket sendEvent:@"get.discounts" withData:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [discounts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"discount";
	static NSString *checkedCellIdentifier = @"discountCheck";
	
	NSString *identifier = CellIdentifier;
	if (group) {
		identifier = checkedCellIdentifier;
	}
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
	Discount *discount = [discounts objectAtIndex:indexPath.row];
	cell.textLabel.text = [discount name];
	if (group) {
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%.2f%@", discount.discountPercent ? @"" : @"£", [discount value], discount.discountPercent ? @"%" : @""];
		
		bool found = false;
		for (NSString *discountId in group.discounts) {
			if ([discountId isEqualToString:discount._id]) {
				found = true;
				break;
			}
		}
		
		if (found) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!group) {
		[self performSegueWithIdentifier:@"openDiscount" sender:[discounts objectAtIndex:indexPath.row]];
		return;
	}
	
	Discount *discount = [discounts objectAtIndex:indexPath.row];
	int found = -1;
	for (int i = 0; i < self.group.discounts.count; i++) {
		NSString *discountId = [self.group.discounts objectAtIndex:i];
		if ([discountId isEqualToString:discount._id]) {
			found = i;
			break;
		}
	}
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	NSMutableArray *_discounts = [self.group.discounts mutableCopy];
	
	if (found != -1) {
		// Uncheck..
		cell.accessoryType = UITableViewCellAccessoryNone;
		[_discounts removeObjectAtIndex:found];
	} else {
		// Check..
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		[_discounts addObject:discount._id];
	}
	
	NSMutableIndexSet *toRemove = [[NSMutableIndexSet alloc] init];
	
	// Do a check for nonexisting Discount IDs
	for (int i = 0; i < _discounts.count; i++) {
		NSString *__did = [_discounts objectAtIndex:i];
		bool __found = false;
		
		for (int x = 0; x < discounts.count; x++) {
			Discount *__discount = [discounts objectAtIndex:x];
			if ([__did isEqualToString:__discount._id]) {
				__found = true;
				break;
			}
		}
		
		if (!__found) {
			// Extraneous
			[toRemove addIndex:i];
		}
	}
	
	[_discounts removeObjectsAtIndexes:toRemove];
	
	self.group.discounts = [_discounts copy];
	[self.group save];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
