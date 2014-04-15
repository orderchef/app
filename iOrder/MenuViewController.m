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
#import "Employee.h"
#import "ItemController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "Order.h"
#import "SubMenuViewController.h"

@interface MenuViewController () {
	NSArray *categories;
	NSArray *titles;
}

@end

@implementation MenuViewController

@synthesize table;
@synthesize activeOrder;
@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.navigationItem setRightBarButtonItem:nil];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [self setRefreshControl:[[UIRefreshControl alloc] init]];
    [self.refreshControl addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
    
    [self setTitle];
    
    [self reloadData];
}

- (void)setTitle {
	if (!table) {
		[self.navigationItem setTitle:@"Items"];
	} else {
		[self.navigationItem setTitle:@"Add to Basket"];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
    [self reloadData];
	[[Storage getStorage] addObserver:self forKeyPath:@"items" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
    @try {
        [[Storage getStorage] removeObserver:self forKeyPath:@"items"];
		[[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:UIDeviceOrientationDidChangeNotification context:nil];
    } @catch (NSException *exception) {}
}

- (void)refreshData:(id)sender {
    [[Storage getStorage] loadData];
}

- (void)reloadData {
    Storage *storage = [Storage getStorage];
    
    NSMutableDictionary *secs = [[NSMutableDictionary alloc] init];
    
    NSArray *items;
	items = [storage items];
	
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
	
	NSArray *sortedTitles = [[secs allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	NSMutableArray *sortedCategories = [[NSMutableArray alloc] initWithCapacity:categories.count];
	
	for (NSString *key in sortedTitles) {
		[sortedCategories addObject:[secs objectForKey:key]];
	}
	
	titles = sortedTitles;
	categories = sortedCategories;
	
    [self.tableView reloadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"items"]) {
        [self reloadData];
        [self.refreshControl endRefreshing];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"SubMenu"]) {
		SubMenuViewController *vc = (SubMenuViewController *)[segue destinationViewController];
		vc.table = table;
		vc.activeOrder = activeOrder;
		vc.delegate = self.delegate;
        vc.category = (NSString *)sender;
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) return 1;
	
    return [titles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"category";
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	
	if (indexPath.section == 0) {
		cell.textLabel.text = @"All Categories";
	} else {
		cell.textLabel.text = [titles objectAtIndex:indexPath.row];
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *category = @"";
	if (indexPath.section > 0) {
		category = [titles objectAtIndex:indexPath.row];
	}
	
	[self performSegueWithIdentifier:@"SubMenu" sender:category];
}

#pragma mark - MenuControlDelegate

- (void)didSelectItem:(Item *)item {
	if (table) {
		[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:[@"Adding " stringByAppendingString:item.name] detail:Nil hideAfter:0.5 showAnimated:NO hideAnimated:NO hide:NO tapRecognizer:nil toView:self.parentViewController.view];
		
		[activeOrder addItem:item andAcknowledge:^(id args) {
			[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:[item.name stringByAppendingString:@" Added"] detail:Nil hideAfter:0.5 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:self.parentViewController.view];
			[[self delegate] didSelectItem:item];
			
			[self.navigationController popViewControllerAnimated:YES];
		}];
		
		return;
	}
}

@end