//
//  ReportItemsViewController.m
//  OrderChef
//
//  Created by Matej Kramny on 02/01/2014.
//  Copyright (c) 2014 Matej Kramny. All rights reserved.
//

#import "ReportItemsViewController.h"

@interface ReportItemsViewController () {
	NSArray *items;
}

@end

@implementation ReportItemsViewController

@synthesize reports;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self aggregate];
	[self.navigationItem setTitle:@"Items Sold"];
}

- (void)aggregate {
	NSMutableDictionary *_items = [[NSMutableDictionary alloc] init];
	
	for (NSDictionary *order in reports) {
		for (NSDictionary *item in [order objectForKey:@"items"]) {
			NSString *_id = [item objectForKey:@"_id"];
			NSMutableDictionary *_item = [_items objectForKey:_id];
			
			if (_item == nil) {
				[_items setObject:[[NSMutableDictionary alloc] initWithDictionary:item] forKey:_id];
			} else {
				float total = [[_item objectForKey:@"total"] floatValue];
				int quantity = [[_item objectForKey:@"quantity"] intValue];
				
				quantity += [[item objectForKey:@"quantity"] intValue];
				total += [[item objectForKey:@"total"] floatValue];
				
				[_item setObject:[NSNumber numberWithFloat:total] forKey:@"total"];
				[_item setObject:[NSNumber numberWithInt:quantity] forKey:@"quantity"];
			}
		}
	}
	
	items = [[_items allValues] sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {
		return [[b objectForKey:@"quantity"] intValue] - [[a objectForKey:@"quantity"] intValue];
	}];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"item";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
	NSDictionary *item = [items objectAtIndex:indexPath.row];
	
	cell.textLabel.text = [item objectForKey:@"name"];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%d sold (£%.2f)", [[item objectForKey:@"quantity"] intValue], [[item objectForKey:@"total"] floatValue]];
	
    return cell;
}

@end
