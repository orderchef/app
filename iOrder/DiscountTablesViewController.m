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

@interface DiscountTablesViewController () {
	NSArray *tables;
	NSArray *titles;
}

@end

@implementation DiscountTablesViewController

@synthesize discount;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self reloadData];
}

- (BOOL)isSelected:(Table *)table {
	for (NSString *_id in discount.tables) {
		if ([_id isEqualToString:table._id]) return true;
	}
	
	return false;
}

static NSComparisonResult (^compareTables)(Table *, Table *) = ^NSComparisonResult(Table *a, Table *b) {
	return [a.name compare:b.name];
};

- (void)reloadData {
	Storage *storage = [Storage getStorage];
	tables = [storage tables];
	
	NSMutableArray *_tables = [[NSMutableArray alloc] init];
	NSMutableArray *takeaway = [[NSMutableArray alloc] init];
	NSMutableArray *delivery = [[NSMutableArray alloc] init];
	
	for (Table *t in storage.tables) {
		if (t.delivery) [delivery addObject:t];
		else if (t.takeaway) [takeaway addObject:t];
		else [_tables addObject:t];
	}
	
	NSMutableArray *ts = [[NSMutableArray alloc] initWithCapacity:3];
	NSMutableArray *tits = [[NSMutableArray alloc] initWithCapacity:3];
	if (takeaway.count > 0) {
		[ts addObject:[takeaway sortedArrayUsingComparator:compareTables]];
		[tits addObject:@"Takeaway"];
	}
	if (delivery.count > 0) {
		[ts addObject:[delivery sortedArrayUsingComparator:compareTables]];
		[tits addObject:@"Delivery"];
	}
	if (_tables.count > 0) {
		[ts addObject:[_tables sortedArrayUsingComparator:compareTables]];
		[tits addObject:@"Tables"];
	}
	
	tables = ts;
	titles = tits;
	
	[self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [tables count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[tables objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	Table *table = [[tables objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	cell.textLabel.text = table.name;
	
	bool selected = [self isSelected:table];
	
	UITableViewCellAccessoryType a_type = UITableViewCellAccessoryNone;
	if (selected) {
		a_type = UITableViewCellAccessoryCheckmark;
	}
	cell.accessoryType = a_type;
	
	cell.backgroundColor = [UIColor colorWithWhite:0.98f alpha:1.0f];
    cell.layer.borderWidth = 0.5f;
    cell.layer.borderColor = [UIColor colorWithWhite:0.9f alpha:1.0f].CGColor;
    [cell backgroundView].backgroundColor = [UIColor blackColor];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Table *table = [[tables objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	UITableViewCellAccessoryType a_type;
	
	NSMutableArray *_tables = [discount.tables mutableCopy];
	if ([self isSelected:table]) {
		[_tables removeObjectIdenticalTo:table._id];
		a_type = UITableViewCellAccessoryNone;
	} else {
		[_tables addObject:table._id];
		a_type = UITableViewCellAccessoryCheckmark;
	}
	
	discount.tables = [_tables copy];
	
	[tableView deselectRowAtIndexPath:indexPath animated:true];
	[[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:a_type];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)view;
        v.textLabel.textAlignment = NSTextAlignmentCenter;
        v.textLabel.textColor = [UIColor colorWithRed:0.203f green:0.444f blue:0.768f alpha:1.f];
        v.backgroundView.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.95f];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [titles objectAtIndex:section];
}

@end
