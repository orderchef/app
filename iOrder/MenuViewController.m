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
	NSArray *items;
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
    
    [[Storage getStorage] addObserver:self forKeyPath:@"items" options:NSKeyValueObservingOptionNew context:nil];
    
    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [self reloadData];
}

- (void)dealloc {
    @try {
        [[Storage getStorage] removeObserver:self forKeyPath:@"items"];
    } @catch (NSException *exception) {}
}

- (void)newItem:(id) sender {
	[self performSegueWithIdentifier:@"newItem" sender:nil];
}

- (void)closeView:(id)sender {
	[[self navigationController] popViewControllerAnimated:YES];
}

- (void)reloadData {
    Storage *storage = [Storage getStorage];
    items = [storage items];
    
    [self.tableView reloadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"items"]) {
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
    return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"menu";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	Item *item = [items objectAtIndex:indexPath.row];
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"£%f", [item.price floatValue]];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Item *item = [items objectAtIndex:indexPath.row];
    [table addItem:item];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

@end