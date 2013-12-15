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
#import "Staff.h"
#import "ItemController.h"

@interface MenuViewController () {
	NSArray *categories;
    NSArray *titles;
	Item *newItem;
}

@end

@implementation MenuViewController

@synthesize table;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    if ([[[Storage getStorage] employee] manager] && !table) {
		[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"New Item" style:UIBarButtonItemStylePlain target:self action:@selector(newItem:)]];
    } else {
		[self.navigationItem setRightBarButtonItem:nil];
    }
    
    [[Storage getStorage] addObserver:self forKeyPath:@"items" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [self setRefreshControl:[[UIRefreshControl alloc] init]];
    [self.refreshControl addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
    
	if (!table) {
		[self.navigationItem setTitle:@"Items"];
	} else {
		[self.navigationItem setTitle:@"Add to Basket"];
	}
	
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

- (void)refreshData:(id)sender {
    [[Storage getStorage] loadData];
}

- (void)newItem:(id) sender {
	newItem = [[Item alloc] init];
	[self performSegueWithIdentifier:@"Item" sender:newItem];
}

- (void)reloadData {
    Storage *storage = [Storage getStorage];
    
    NSMutableDictionary *secs = [[NSMutableDictionary alloc] init];
    
    NSArray *items = [storage items];
    for (Item *i in items) {
        ItemCategory *category = i.category;
        
        NSString *section;
        if (!category) {
            section = @"Uncategorised";
        } else {
            section = [category name];
        }
        
        NSMutableArray *sec = [secs objectForKey:section];
        if (!sec) {
            sec = [[NSMutableArray alloc] init];
            [secs setObject:sec forKey:section];
        }
        
        [sec addObject:i];
    }
    
    categories = [secs allValues];
    titles = [secs allKeys];
    
    [self.tableView reloadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"items"]) {
        [self reloadData];
        [self.refreshControl endRefreshing];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"Item"]) {
		ItemController *vc = (ItemController *)[segue destinationViewController];
		vc.item = (Item *)sender;
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [categories count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[categories objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"menu";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	Item *item = [[categories objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"£%.2f", [item.price floatValue]];
	
    cell.backgroundColor = [UIColor colorWithWhite:0.98f alpha:1.0f];
    cell.layer.borderWidth = 0.5f;
    cell.layer.borderColor = [UIColor colorWithWhite:0.9f alpha:1.0f].CGColor;
    [cell backgroundView].backgroundColor = [UIColor blackColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Item *item = [[categories objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	
	if (table) {
		[table addItem:item];
		[self.navigationController popViewControllerAnimated:YES];
		
		return;
	}
	
	[self performSegueWithIdentifier:@"Item" sender:item];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)view;
        v.textLabel.textAlignment = NSTextAlignmentCenter;
        v.textLabel.textColor = [UIColor colorWithRed:0.203f green:0.444f blue:0.768f alpha:1.f];
        v.backgroundView.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.95f];
        //v.backgroundView.layer.borderColor = [UIColor grayColor].CGColor;
        //v.backgroundView.layer.borderWidth = 0.5f;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [titles objectAtIndex:section];
}

@end