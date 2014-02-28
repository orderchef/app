//
//  DiscountCategoriesViewController.m
//  OrderChef
//
//  Created by Matej Kramny on 28/02/2014.
//  Copyright (c) 2014 Matej Kramny. All rights reserved.
//

#import "DiscountCategoriesViewController.h"
#import "Storage.h"
#import "Discount.h"
#import "ItemCategory.h"

@interface DiscountCategoriesViewController ()

@end

@implementation DiscountCategoriesViewController

@synthesize discount;

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (BOOL)isSelected:(ItemCategory *)category {
	for (NSString *_id in discount.categories) {
		if ([_id isEqualToString:category._id]) return true;
	}
	
	return false;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[Storage getStorage] categories].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	ItemCategory *cat = [[[Storage getStorage] categories] objectAtIndex:indexPath.row];
	cell.textLabel.text = cat.name;
	
	bool selected = [self isSelected:cat];
	
	UITableViewCellAccessoryType a_type = UITableViewCellAccessoryNone;
	if (selected) {
		a_type = UITableViewCellAccessoryCheckmark;
	}
	cell.accessoryType = a_type;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ItemCategory *category = [[Storage getStorage].categories objectAtIndex:indexPath.row];
	UITableViewCellAccessoryType a_type;
	
	NSMutableArray *cats = [discount.categories mutableCopy];
	if ([self isSelected:category]) {
		[cats removeObjectIdenticalTo:category._id];
		a_type = UITableViewCellAccessoryNone;
	} else {
		[cats addObject:category._id];
		a_type = UITableViewCellAccessoryCheckmark;
	}
	
	discount.categories = [cats copy];
	
	[tableView deselectRowAtIndexPath:indexPath animated:true];
	[[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:a_type];
}

@end
