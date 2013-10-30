//
//  MenuViewController.m
//  iOrder
//
//  Created by Matej Kramny on 28/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "MenuViewController.h"
#import "AppDelegate.h"
#import "Item.h"
#import "ItemCategory.h"
#import "Table.h"

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
	NSManagedObjectContext *context = [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
    
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemCategory"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
	NSError *error;
    categories = [context executeFetchRequest:fetchRequest error:&error];
    
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
    return [[[category items] allObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"menu";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	ItemCategory *category = [categories objectAtIndex:indexPath.section];
	Item *item = [[[category items] allObjects] objectAtIndex:indexPath.row];
	cell.textLabel.text = item.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"£%f", [item.price floatValue]];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ItemCategory *category = [categories objectAtIndex:indexPath.section];
    Item *item = [[[category items] allObjects] objectAtIndex:indexPath.row];
    [item setTable:table];
    [table addItemsObject:item];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[categories objectAtIndex:section] name];
}

@end