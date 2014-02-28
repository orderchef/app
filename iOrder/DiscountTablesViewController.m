//
//  DiscountCategoriesViewController.m
//  OrderChef
//
//  Created by Matej Kramny on 28/02/2014.
//  Copyright (c) 2014 Matej Kramny. All rights reserved.
//

#import "DiscountTablesViewController.h"
#import "Storage.h"
#import "Discount.h"
#import "Table.h"

@interface DiscountTablesViewController ()

@end

@implementation DiscountTablesViewController

@synthesize discount;

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (BOOL)isSelected:(Table *)table {
	for (NSString *_id in discount.tables) {
		if ([_id isEqualToString:table._id]) return true;
	}
	
	return false;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[Storage getStorage] tables].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	Table *table = [[[Storage getStorage] tables] objectAtIndex:indexPath.row];
	cell.textLabel.text = table.name;
	
	bool selected = [self isSelected:table];
	
	UITableViewCellAccessoryType a_type = UITableViewCellAccessoryNone;
	if (selected) {
		a_type = UITableViewCellAccessoryCheckmark;
	}
	cell.accessoryType = a_type;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Table *table = [[Storage getStorage].tables objectAtIndex:indexPath.row];
	UITableViewCellAccessoryType a_type;
	
	NSMutableArray *tables = [discount.tables mutableCopy];
	if ([self isSelected:table]) {
		[tables removeObjectIdenticalTo:table._id];
		a_type = UITableViewCellAccessoryNone;
	} else {
		[tables addObject:table._id];
		a_type = UITableViewCellAccessoryCheckmark;
	}
	
	discount.tables = [tables copy];
	
	[tableView deselectRowAtIndexPath:indexPath animated:true];
	[[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:a_type];
}

@end
