//
//  DiscountsViewController.m
//  OrderChef
//
//  Created by Matej Kramny on 07/02/2014.
//  Copyright (c) 2014 Matej Kramny. All rights reserved.
//

#import "DiscountViewController.h"

@interface DiscountViewController ()

@end

@implementation DiscountViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.navigationController setTitle:@"Discount"];
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
