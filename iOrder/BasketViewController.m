//
//  BasketViewController.m
//  iOrder
//
//  Created by Matej Kramny on 02/11/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "BasketViewController.h"
#import "Table.h"
#import "Item.h"
#import "MenuViewController.h"

@interface BasketViewController () {
    UIRefreshControl *refreshControl;
}

@end

@implementation BasketViewController

@synthesize table, tableView = _tableView, toolbar = _toolbar;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [table addObserver:self forKeyPath:@"items" options:NSKeyValueObservingOptionNew context:nil];
    [table loadItems];
    
    [self.toolbar setItems:@[
                             [[UIBarButtonItem alloc] initWithTitle:@"Clear table" style:UIBarButtonItemStylePlain target:self action:@selector(clear:)],
                             [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                             [[UIBarButtonItem alloc] initWithTitle:@"Send to Kitchen" style:UIBarButtonItemStylePlain target:self action:@selector(sendToKitchen:)]
    ] animated:YES];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshBasket:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
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
        [refreshControl endRefreshing];
    }
}

- (void)refreshBasket:(id)sender {
    [self.table loadItems];
}

- (void)reloadData {
	[self.tableView reloadData];
}

- (void)clear:(id)sender {
    [table clearTable];
    [table setItems:@[]];
    [self reloadData];
}
- (void)sendToKitchen:(id)sender {
    [table sendToKitchen];
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
        [self performSegueWithIdentifier:@"openMenu" sender:nil];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
