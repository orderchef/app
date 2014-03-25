//
//  MenuViewController.m
//  iOrder
//
//  Created by Matej Kramny on 28/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "SubMenuViewController.h"
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

@interface SubMenuViewController () {
	NSArray *categories;
    NSArray *titles;
	Item *newItem;
}

@end

@implementation SubMenuViewController

@synthesize table;
@synthesize activeOrder;
@synthesize delegate;
@synthesize category;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if ([[[Storage getStorage] employee] manager] && !table) {
		[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newItem:)]];
    } else {
		[self.navigationItem setRightBarButtonItem:nil];
    }
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [self setRefreshControl:[[UIRefreshControl alloc] init]];
    [self.refreshControl addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
    
	[self.navigationItem setTitle:category];
	
    [self reloadData];
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

- (void)newItem:(id) sender {
	newItem = [[Item alloc] init];
	[self performSegueWithIdentifier:@"Item" sender:newItem];
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
		
		if (![section isEqualToString:self.category]) {
			continue;
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

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	NSMutableArray *titles_single = [[NSMutableArray alloc] initWithCapacity:titles.count];
	for (NSString *title in titles) {
		[titles_single addObject:[title substringToIndex:1]];
	}
	
	return titles_single;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[categories objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"menu";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
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
		[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:[@"Adding " stringByAppendingString:item.name] detail:Nil hideAfter:0.5 showAnimated:NO hideAnimated:NO hide:NO tapRecognizer:nil toView:self.parentViewController.view];
		
		[activeOrder addItem:item andAcknowledge:^(id args) {
			[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:[item.name stringByAppendingString:@" Added"] detail:Nil hideAfter:0.5 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:self.parentViewController.view];
			[[self delegate] didSelectItem:item];
			
			UIViewController *controller = nil;
			for (UIViewController *vc in [self.navigationController viewControllers]) {
				if ([vc conformsToProtocol:@protocol(MenuControlDelegate)]) {
					controller = vc;
					break;
				}
			}
			[self.navigationController popToViewController:controller animated:YES];
		}];
		
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
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [titles objectAtIndex:section];
}

@end