//
//  ReportItemsViewController.m
//  OrderChef
//
//  Created by Matej Kramny on 02/01/2014.
//  Copyright (c) 2014 Matej Kramny. All rights reserved.
//

#import "ReportItemsViewController.h"
#import "Connection.h"
#import "AppDelegate.h"

@interface ReportItemsViewController () {
	NSArray *items;
}

@end

@implementation ReportItemsViewController

@synthesize reports;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"\uf02f " style:UIBarButtonItemStylePlain target:self action:@selector(print:)] animated:true];
	[self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{
																	 NSFontAttributeName: [UIFont fontWithName:@"FontAwesome" size:24]
																	 } forState:UIControlStateNormal];
	
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

- (void)print:(id)sender {
	NSMutableString *string = [[NSMutableString alloc] init];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"EEEE dd MMMM yyyy"];
	NSString *dayName = [dateFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[[reports objectAtIndex:0] objectForKey:@"time"] intValue]]];
	
	[string appendFormat:@"Report for %@\n", dayName];
	
	for (NSDictionary *item in items) {
		[string appendFormat:@" %@, %d sold (%.2f GBP)\n", [item objectForKey:@"name"], [[item objectForKey:@"quantity"] intValue], [[item objectForKey:@"total"] floatValue]];
	}
	
	[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:@"Print Data Sent" detail:@"Please check your receipt printer." hideAfter:0.5 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:self.navigationController.view];
	
	[[[Connection getConnection] socket] sendEvent:@"print" withData:@{@"data": string, @"receiptPrinter": [NSNumber numberWithBool:YES]}];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
