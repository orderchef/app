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

@interface MenuViewController () {
	NSArray *categories;
    NSArray *titles;
	NSString *searchText;
	Item *newItem;
	
	CGPoint kNavbarDefaultPosition;
	CGPoint kNavbarMinimalPosition;
	CGPoint kTableDefaultPosition;
	CGPoint kTableMinimalPosition;
	CGFloat kTableDefaultHeight;
	CGFloat kTableMaximumHeight;
	
	bool isNavbarHidden;
	bool isOverlayHidden;
	
	UIView *blackOverlay;
	UITapGestureRecognizer *tapRecognizer;
}

@end

@implementation MenuViewController

@synthesize table;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	isNavbarHidden = false;
	isOverlayHidden = true;
	
	kNavbarDefaultPosition = self.navigationController.navigationBar.layer.position;
	kNavbarMinimalPosition = CGPointMake(kNavbarDefaultPosition.x, kNavbarDefaultPosition.y - self.searchBar.frame.size.height);
	kTableDefaultPosition = self.tableView.layer.position;
	kTableMinimalPosition = CGPointMake(kTableDefaultPosition.x, kTableDefaultPosition.y - self.searchBar.frame.size.height);
	kTableDefaultHeight = self.tableView.frame.size.height;
	kTableMaximumHeight = self.tableView.frame.size.height + 44.f;
	
	blackOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 44.f, self.tableView.frame.size.width, self.tableView.frame.size.height)];
	tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetSearchBar:)];
	[tapRecognizer setCancelsTouchesInView:YES];
	[blackOverlay addGestureRecognizer:tapRecognizer];
	
    if ([[[Storage getStorage] employee] manager] && !table) {
		[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newItem:)]];
    } else {
		[self.navigationItem setRightBarButtonItem:nil];
    }
    
	searchText = @"";
	
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [self setRefreshControl:[[UIRefreshControl alloc] init]];
    [self.refreshControl addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
    
	if (!table) {
		[self.navigationItem setTitle:@"Items"];
	} else {
		[self.navigationItem setTitle:@"Add to Basket"];
	}
	
	self.searchBar.delegate = self;
	
    [self reloadData];
	
	self.tableView.contentOffset = CGPointMake(0,  self.searchBar.frame.size.height - self.tableView.contentOffset.y);
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
	if (searchText.length > 0) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchText];
		items = [[storage items] filteredArrayUsingPredicate:predicate];
	} else {
		items = [storage items];
	}
	
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
	if ([segue.identifier isEqualToString:@"Item"]) {
		ItemController *vc = (ItemController *)[segue destinationViewController];
		vc.item = (Item *)sender;
	}
}

- (void)resetSearchBar:(id)sender {
	[self.searchBar resignFirstResponder];
	[self hideOverlay];
}

- (void)hideNavbar {
	if (isNavbarHidden == true) {
		return;
	}
	
	isNavbarHidden = true;
	CABasicAnimation *navAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
	CABasicAnimation *tabAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
	
	navAnimation.duration = 0.2f;
	navAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
	navAnimation.fillMode = kCAFillModeForwards;
	
	tabAnimation.duration = 0.2f;
	tabAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
	tabAnimation.fillMode = kCAFillModeForwards;
	
	CALayer *navLayer = self.navigationController.navigationBar.layer;
	CALayer *tabLayer = self.tableView.layer;
	
	navAnimation.fromValue = [NSValue valueWithCGPoint:kNavbarDefaultPosition];
	tabAnimation.fromValue = [NSValue valueWithCGPoint:kTableDefaultPosition];
	navAnimation.toValue = [NSValue valueWithCGPoint:kNavbarMinimalPosition];
	tabAnimation.toValue = [NSValue valueWithCGPoint:kTableMinimalPosition];
	
	navLayer.position = kNavbarMinimalPosition;
	tabLayer.position = kTableMinimalPosition;
	
	[navLayer addAnimation:navAnimation forKey:@"position"];
	[tabLayer addAnimation:tabAnimation forKey:@"position"];
	
	[self.navigationItem setHidesBackButton:YES animated:YES];
	[self.navigationItem setRightBarButtonItem:Nil animated:YES];
	[self.navigationItem setTitle:@""];
}

- (void)showNavbar {
	if (isNavbarHidden == false) {
		return;
	}
	
	isNavbarHidden = false;
	[self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, kTableDefaultHeight)];
	
	CABasicAnimation *navAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
	CABasicAnimation *tabAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
	
	navAnimation.duration = 0.2f;
	navAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
	navAnimation.fillMode = kCAFillModeForwards;
	
	tabAnimation.duration = 0.2f;
	tabAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
	tabAnimation.fillMode = kCAFillModeForwards;
	
	CALayer *navLayer = self.navigationController.navigationBar.layer;
	CALayer *tabLayer = self.tableView.layer;
	
	navAnimation.fromValue = [NSValue valueWithCGPoint:kNavbarMinimalPosition];
	tabAnimation.fromValue = [NSValue valueWithCGPoint:kTableMinimalPosition];
	navAnimation.toValue = [NSValue valueWithCGPoint:kNavbarDefaultPosition];
	tabAnimation.toValue = [NSValue valueWithCGPoint:kTableDefaultPosition];
	
	navLayer.position = kNavbarDefaultPosition;
	tabLayer.position = kTableDefaultPosition;
	
	[navLayer addAnimation:navAnimation forKey:@"position"];
	[tabLayer addAnimation:tabAnimation forKey:@"position"];
	
	[self.navigationItem setHidesBackButton:NO animated:YES];
	if ([[[Storage getStorage] employee] manager] && !table) {
		[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newItem:)]];
	}
	[self setTitle];
}

- (void)showOverlay {
	if (isOverlayHidden == false) {
		return;
	}
	
	isOverlayHidden = false;
	[blackOverlay setBackgroundColor:[UIColor colorWithWhite:0.f alpha:0.0f]];
	self.tableView.scrollEnabled = NO;
	[self.view addSubview:blackOverlay];
	[UIView animateWithDuration:0.3f animations:^(void) {
		[blackOverlay setBackgroundColor:[UIColor colorWithWhite:0.f alpha:0.7f]];
	}];
}

- (void)hideOverlay:(float)afterDelay {
	if (isOverlayHidden == true) {
		return;
	}
	
	isOverlayHidden = true;
	self.tableView.scrollEnabled = YES;
	[UIView animateWithDuration:afterDelay animations:^(void) {
		[blackOverlay setBackgroundColor:[UIColor colorWithWhite:0.f alpha:0.0f]];
	}];
	
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(afterDelay * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[blackOverlay removeFromSuperview];
	});
}

- (void)hideOverlay {
	[self hideOverlay:0.2f];
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
	[self.searchBar resignFirstResponder];
	[self hideOverlay];
	[self showNavbar];
	
	Item *item = [[categories objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	
	if (table) {
		[table addItem:item];
		
		[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:[item.name stringByAppendingString:@" Added"] detail:Nil hideAfter:0.5 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:self.parentViewController.view];
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

#pragma mark - Search Delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[searchBar setText:@""];
	[searchBar resignFirstResponder];
	[self.searchBar setShowsCancelButton:NO animated:YES];
	
	[self searchBar:searchBar textDidChange:@""];
	
	[self showNavbar];
	[self hideOverlay];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)aSearchText {
	searchText = aSearchText;
	[self reloadData];
	
	if (searchText.length > 0) {
		[self.searchBar setShowsSearchResultsButton:YES];
		[self hideOverlay:0.f];
	} else {
		[self.searchBar setShowsSearchResultsButton:NO];
		[self showOverlay];
	}
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	[self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, kTableDefaultHeight)];
	[self hideNavbar];
	[self.searchBar setShowsCancelButton:YES animated:YES];
	
	[self showOverlay];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	if (searchText.length == 0) {
		[self showNavbar];
		[self.searchBar setShowsCancelButton:NO animated:YES];
	}
	
	[self hideOverlay];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	[self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, kTableMaximumHeight)];
}

@end