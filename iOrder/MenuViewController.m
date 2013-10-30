//
//  MenuViewController.m
//  iOrder
//
//  Created by Matej Kramny on 28/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "MenuViewController.h"
#import "Item.h"
#import "ItemCategory.h"
#import "Table.h"
#import "Storage.h"

@interface MenuViewController () {
	NSArray *categories;
}

@end

@implementation MenuViewController

@synthesize table;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.navigationItem.rightBarButtonItem setTarget:self];
	[self.navigationItem.rightBarButtonItem setAction:@selector(newItem:)];
	[self.navigationItem.leftBarButtonItem setTarget:self];
	[self.navigationItem.leftBarButtonItem setAction:@selector(closeView:)];
    
    [self reloadData];
}

- (void)newItem:(id) sender {
	[self performSegueWithIdentifier:@"newItem" sender:nil];
}

- (void)closeView:(id)sender {
	[[self navigationController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)reloadData {
    Storage *storage = [Storage getStorage];
    categories = [storage categories];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [categories count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	ItemCategory *category = [categories objectAtIndex:section];
    return [[category items] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"menu";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	ItemCategory *category = [categories objectAtIndex:indexPath.section];
	Item *item = [[category items] objectAtIndex:indexPath.row];
	cell.textLabel.text = item.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"£%f", [item.price floatValue]];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ItemCategory *category = [categories objectAtIndex:indexPath.section];
    Item *item = [[category items] objectAtIndex:indexPath.row];
    [item setTable:table];
    [[table items] addObject:item];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[categories objectAtIndex:section] name];
}

@end