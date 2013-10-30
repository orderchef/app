//
//  BasketViewController.m
//  iOrder
//
//  Created by Matej Kramny on 28/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "BasketViewController.h"
#import "Table.h"
#import "Item.h"
#import "MenuViewController.h"

@interface BasketViewController ()

@end

@implementation BasketViewController

@synthesize table;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.navigationItem.rightBarButtonItem setTarget:self];
	[self.navigationItem.rightBarButtonItem setAction:@selector(openMenu:)];
    
    [table addObserver:self forKeyPath:@"items" options:NSKeyValueObservingOptionNew context:nil];
    [table loadItems];
    
    [self reloadData];
}

- (void)dealloc {
    @try {
        [table removeObserver:self forKeyPath:@"items"];
    }
    @catch (NSException *exception) {}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"items"]) {
        [self reloadData];
    }
}

- (void)openMenu:(id) sender {
	[self performSegueWithIdentifier:@"openMenu" sender:nil];
}

- (void)reloadData {
	[self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return section == 0 ? 1 : [[table items] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"basket";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"Order more items";
        cell.detailTextLabel.text = @"";
    } else {
        NSDictionary *item = [[table items] objectAtIndex:indexPath.row];
        Item *it = [item objectForKey:@"item"];
        cell.textLabel.text = it.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"£%fx%@", [it.price floatValue], (NSNumber *)[item objectForKey:@"quantity"]];
    }
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self openMenu:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"openMenu"]) {
        MenuViewController *vc = (MenuViewController *)segue.destinationViewController;
		vc.table = table;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section == 1 ? @"Items in basket" : @"";
}

@end
