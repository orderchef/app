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
		
	}
}

- (void)didReceiveNotification:(NSNotification *)notification {
	if ([[notification name] isEqualToString:kReportsNotificationName]) {
		NSDictionary *discounts = [notification userInfo];
		
		[self.tableView reloadData];
		[self.refreshControl endRefreshing];
	}
}

- (void)refresh {
	[[Connection getConnection].socket sendEvent:@"get.discounts" withData:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    return cell;
}

@end
