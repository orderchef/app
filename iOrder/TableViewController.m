//
//  TableViewController.m
//  iOrder
//
//  Created by Matej Kramny on 27/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "TableViewController.h"
#import "AppDelegate.h"
#import "Table.h"
#import "BasketViewController.h"
#import "MenuViewController.h"
#import "Storage.h"

@interface TableViewController () {
    NSArray *tables;
}

@end

@implementation TableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem.rightBarButtonItem setTarget:self];
    [self.navigationItem.rightBarButtonItem setAction:@selector(addTable:)];
    
    [self reloadData];
}

- (void)reloadData {
    Storage *storage = [Storage getStorage];
    tables = [storage tables];
    
    [self.tableView reloadData];
}

- (void)addTable:(id)sender {
	UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Enter Table name" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
	[view setAlertViewStyle:UIAlertViewStylePlainTextInput];
	
	[view show];
}

#pragma mark - Alert View

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		Table *table = [[Table alloc] init];
		[table setName:[[alertView textFieldAtIndex:0] text]];
		
		[[[Storage getStorage] tables] addObject:table];
		
		[self reloadData];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tables count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"table";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [[tables objectAtIndex:indexPath.row] name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Table *table = [tables objectAtIndex:indexPath.row];
	if ([table items].count > 0) {
		[self performSegueWithIdentifier:@"openBasket" sender:[tables objectAtIndex:indexPath.row]];
	} else {
		[self performSegueWithIdentifier:@"openMenu" sender:[tables objectAtIndex:indexPath.row]];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"openBasket"]) {
		BasketViewController *vc = (BasketViewController *)[segue destinationViewController];
		vc.table = (Table *)sender;
	} else if ([[segue identifier] isEqualToString:@"openMenu"]) {
		MenuViewController *vc = (MenuViewController *)[segue.destinationViewController topViewController];
		vc.table = (Table *)sender;
	}
}

@end
