//
//  CategoryViewController.m
//  iOrder
//
//  Created by Matej Kramny on 21/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "CategoryViewController.h"
#import "TextFieldCell.h"
#import "ItemCategory.h"

@interface CategoryViewController () {
	BOOL save;
}

@end

@implementation CategoryViewController

@synthesize category;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	save = true;
	
	[self.navigationItem setTitle:category.name];
	if (category.name.length == 0) {
        [self.navigationItem setTitle:@"Enter a Name"];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	if (save && category.name.length > 0) {
        [category save];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (category._id.length > 0)
		return 3;
	
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
		return 1;
	} else if (section == 2) {
		return 1;
	}
	
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"text";
    
	if (indexPath.section == 0) {
		TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
		if (!cell) {
			cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		}
		
		cell.textField.text = category.name;
		
		return cell;
	}
	if (indexPath.section == 2) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basic" forIndexPath:indexPath];
		
		cell.textLabel.text = @"Delete Category";
		cell.textLabel.textAlignment = NSTextAlignmentCenter;
		
		return cell;
	}
	
	return nil;
}

@end
