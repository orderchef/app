//
//  DiscountsViewController.m
//  OrderChef
//
//  Created by Matej Kramny on 07/02/2014.
//  Copyright (c) 2014 Matej Kramny. All rights reserved.
//

#import "DiscountViewController.h"
#import "TextFieldCell.h"

@interface DiscountViewController ()

@end

@implementation DiscountViewController

@synthesize discount;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.navigationItem setTitle:@"New Discount"];
	if (discount) {
		[self.navigationItem setTitle:[discount objectForKey:@"name"]];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"text";
    TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	if (!cell) {
		cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	cell.textField.placeholder = @"Discount Name";
	if (discount) {
		cell.textField.text = [discount objectForKey:@"name"];
	}
	
    return cell;
}

@end
