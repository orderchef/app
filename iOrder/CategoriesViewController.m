//
//  CategoriesViewController.m
//  iOrder
//
//  Created by Matej Kramny on 21/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "CategoriesViewController.h"
#import "Storage.h"
#import "Item.h"
#import "ItemCategory.h"
#import "CategoryViewController.h"

@interface CategoriesViewController () {
	ItemCategory *newCategory;
	NSIndexPath *selectedCategory;
}

@end

@implementation CategoriesViewController

@synthesize item;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.tableView setAllowsSelectionDuringEditing:YES];
	
	[self setEditing:NO animated:NO];
	
    [self setRefreshControl:[[UIRefreshControl alloc] init]];
    [self.refreshControl addTarget:self action:@selector(reloadCategories:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[[Storage getStorage] addObserver:self forKeyPath:@"categories" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	@try {
        [[Storage getStorage] removeObserver:self forKeyPath:@"categories"];
    } @catch (NSException *exception) {}
}

- (void)reloadCategories:(id)sender {
    [[Storage getStorage] loadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"categories"]) {
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
	if (editing) {
		[self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCategory:)] animated:YES];
		[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleEdit:)] animated:YES];
	} else {
		if (!item) {
			[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCategory:)] animated:YES];
			return;
		}
		[self.navigationItem setLeftBarButtonItem:nil animated:YES];
		[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEdit:)] animated:YES];
	}
}

- (void)addCategory:(id)sender {
	newCategory = [[ItemCategory alloc] init];
	[self performSegueWithIdentifier:@"Category" sender:newCategory];
	
	[self setEditing:NO animated:NO];
}

- (void)toggleEdit:(id)sender {
	[self setEditing:!self.editing animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"Category"]) {
		CategoryViewController *vc = (CategoryViewController *)segue.destinationViewController;
		vc.category = (ItemCategory *)sender;
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[Storage getStorage] categories].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Category";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	ItemCategory *category = [[[Storage getStorage] categories] objectAtIndex:indexPath.row];
	
	if (item) {
		cell.accessoryType = UITableViewCellAccessoryNone;
		if (item.category._id == category._id) {
			selectedCategory = indexPath;
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}
	} else {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	cell.textLabel.text = [category name];
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ItemCategory *category = [[[Storage getStorage] categories] objectAtIndex:indexPath.row];
	
	if (!self.editing && item) {
		item.category = category;
		if (selectedCategory) {
			UITableViewCell *cell = [tableView cellForRowAtIndexPath:selectedCategory];
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		
		selectedCategory = indexPath;
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		
		return;
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self setEditing:NO animated:YES];
	
	[self performSegueWithIdentifier:@"Category" sender:category];
}

@end
