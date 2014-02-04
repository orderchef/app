//
//  PrintersViewController.m
//  OrderChef
//
//  Created by Matej Kramny on 27/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "PrintersViewController.h"
#import "Connection.h"
#import "ItemCategory.h"
#import "AppDelegate.h"

@interface PrintersViewController () {
	NSArray *printers;
}

@end

@implementation PrintersViewController

@synthesize category;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Uncheck All" style:UIBarButtonItemStyleDone target:self action:@selector(removeAll:)] animated:YES];
	
	printers = [NSArray array];
	[self getPrinters];
}

- (void)getPrinters {
	[[Connection getConnection].socket sendEvent:@"get.printers" withData:@{} andAcknowledge:^(NSArray *_printers) {
		NSLog(@"Printers: %@", _printers);
		printers = _printers;
		
		[self.tableView reloadData];
	}];
}

- (void)removeAll:(id)sender {
	category.printers = [[NSArray alloc] init];
	
	[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:@"Cleared All Printers" detail:@"from this Category" hideAfter:0.5 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:self.navigationController.view];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return printers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"basic";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
	NSString *printer = [[printers objectAtIndex:indexPath.row] objectForKey:@"name"];
	cell.textLabel.text = printer;
	
	bool found = false;
	for (NSString *_printer in category.printers) {
		if ([printer isEqualToString:_printer]) {
			found = true;
			break;
		}
	}
	
	if (found) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	NSMutableArray *_printers = [[category printers] mutableCopy];
	NSString *printer = [[printers objectAtIndex:indexPath.row] objectForKey:@"name"];
	if (cell.accessoryType == UITableViewCellAccessoryNone) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		[_printers addObject:printer];
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
		[_printers removeObject:printer];
	}
	
	category.printers = _printers;
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
