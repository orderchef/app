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

@interface DiscountsViewController () {
	NSArray *discounts;
}

@end

@implementation DiscountsViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.navigationItem setTitle:@"Discounts"];
	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addDiscount:)] animated:NO];
	[self setRefreshControl:[[UIRefreshControl alloc] init]];
	[[self refreshControl] addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:kDiscountsNotificationName object:nil];
	[self refresh];
}

- (void)addDiscount:(id)sender {
	[self performSegueWithIdentifier:@"openDiscount" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"openDiscount"]) {
		DiscountViewController *vc = [segue destinationViewController];
		vc.discount = (NSDictionary *)sender;
	}
}

- (void)didReceiveNotification:(NSNotification *)notification {
	if ([[notification name] isEqualToString:kDiscountsNotificationName]) {
		discounts = (NSArray *)[notification userInfo];
		
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	cell.textLabel.text = [[discounts objectAtIndex:indexPath.row] objectForKey:@"name"];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self performSegueWithIdentifier:@"openDiscount" sender:[discounts objectAtIndex:indexPath.row]];
}

@end
