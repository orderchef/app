//
//  TableViewController.m
//  iOrder
//
//  Created by Matej Kramny on 27/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "TablesViewController.h"
#import "AppDelegate.h"
#import "Table.h"
#import "OrdersViewController.h"
#import "OrderViewController.h"
#import "MenuViewController.h"
#import "Storage.h"
#import "Connection.h"
#import "TableViewController.h"
#import "LTHPasscodeViewController.h"
#import "Employee.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "OrderGroup.h"

@interface TablesViewController () {
    NSArray *tables;
	Table *newTable;
	NSArray *titles;
	UIBarButtonItem *managerButton;
}

@end

@implementation TablesViewController

@synthesize manageEnabled;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setRefreshControl:[[UIRefreshControl alloc] init]];
    [self.refreshControl addTarget:self action:@selector(reloadTables:) forControlEvents:UIControlEventValueChanged];
    
	if (self.manageEnabled) {
		[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTable:)] animated:NO];
	} else {
		[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"\uf08b" style:UIBarButtonItemStylePlain target:self action:@selector(logOut:)]];
		
		NSDictionary *faProperties = @{
									   NSFontAttributeName: [UIFont fontWithName:@"FontAwesome" size:24]
									   };
		
		managerButton = [[UIBarButtonItem alloc] initWithTitle:@" \uf0ad" style:UIBarButtonItemStylePlain target:self action:@selector(openManager:)];
		[managerButton setTitleTextAttributes:faProperties forState:UIControlStateNormal];
		
		[self.navigationItem.rightBarButtonItem setTitleTextAttributes:faProperties forState:UIControlStateNormal];
	}
	
	[self.navigationItem setTitle:@"Tables"];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		if ([tables count] > 0) {
			
		}
	}
	
    [self reloadData];
}

- (void)logOut:(id)sender {
	AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
	
	[[LTHPasscodeViewController sharedUser] showLockscreenWithAnimation:NO];
	[delegate showMessage:@"Logged Out" detail:nil hideAfter:0.5 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[[Storage getStorage] addObserver:self forKeyPath:@"tables" options:NSKeyValueObservingOptionNew context:nil];
    [[Storage getStorage] addObserver:self forKeyPath:@"employee" options:NSKeyValueObservingOptionNew context:nil];
	
	[self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	@try {
        [[Storage getStorage] removeObserver:self forKeyPath:@"tables"];
        [[Storage getStorage] removeObserver:self forKeyPath:@"employee"];
    } @catch (NSException *ex) {}
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
	if (!self.manageEnabled) {
		Storage *storage = [Storage getStorage];
		if ([storage employee] == nil) {
			[[LTHPasscodeViewController sharedUser] showLockscreenWithAnimation:YES];
		}
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"tables"]) {
        [self reloadData];
        if ([self.refreshControl isRefreshing]) {
            [self.refreshControl endRefreshing];
        }
		
		Table *activeTable = [Storage getStorage].activeTable;
		if (activeTable) {
			for (int section = 0; section < tables.count; section++) {
				NSArray *rows = [tables objectAtIndex:section];
				for (int row = 0; row < [rows count]; row++) {
					Table *table = [rows objectAtIndex:row];
					
					if ([table._id isEqualToString:activeTable._id]) {
						[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
						break;
					}
				}
			}
		}
    } else if ([keyPath isEqualToString:@"employee"]) {
        Storage *storage = [Storage getStorage];
        [self setEditing:NO animated:NO];
        
		if (!self.manageEnabled && [storage.employee manager]) {
			[self.navigationItem setLeftBarButtonItem:managerButton];
		} else {
			[self.navigationItem setLeftBarButtonItem:nil];
		}
		
        if (![storage employee]) {
            // Lock
            [[LTHPasscodeViewController sharedUser] showLockscreenWithAnimation:YES];
        }
    }
}

- (void)reloadTables:(id)sender {
    [[[Connection getConnection] socket] sendEvent:@"get.tables" withData:nil];
    [self.refreshControl beginRefreshing];
}

static NSComparisonResult (^compareTables)(Table *, Table *) = ^NSComparisonResult(Table *a, Table *b) {
	return [a.name compare:b.name];
};

- (void)reloadData {
	Storage *storage = [Storage getStorage];
    tables = [storage tables];
    
	NSMutableArray *_tables = [[NSMutableArray alloc] init];
	NSMutableArray *takeaway = [[NSMutableArray alloc] init];
	NSMutableArray *delivery = [[NSMutableArray alloc] init];
	
	for (Table *t in storage.tables) {
		if (t.delivery) [delivery addObject:t];
		else if (t.takeaway) [takeaway addObject:t];
		else [_tables addObject:t];
	}
	
	NSMutableArray *ts = [[NSMutableArray alloc] initWithCapacity:3];
	NSMutableArray *tits = [[NSMutableArray alloc] initWithCapacity:3];
	if (takeaway.count > 0) {
		[ts addObject:[takeaway sortedArrayUsingComparator:compareTables]];
		[tits addObject:@"Takeaway"];
	}
	if (delivery.count > 0) {
		[ts addObject:[delivery sortedArrayUsingComparator:compareTables]];
		[tits addObject:@"Delivery"];
	}
	if (_tables.count > 0) {
		[ts addObject:[_tables sortedArrayUsingComparator:compareTables]];
		[tits addObject:@"Tables"];
	}
	
	tables = ts;
	titles = tits;
	
    [self.tableView reloadData];
}

- (void)addTable:(id)sender {
	newTable = [[Table alloc] init];
	[self performSegueWithIdentifier:@"editTable" sender:newTable];
}

- (void)openManager:(id)sender {
	if (![[Storage getStorage].employee manager]) {
		return;
	}
	[self performSegueWithIdentifier:@"openManager" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"openBasket"]) {
		OrdersViewController *vc = (OrdersViewController *)[segue destinationViewController];
		vc.table = (Table *)sender;
		vc.group = vc.table.group;
	} else if ([[segue identifier] isEqualToString:@"openMenu"]) {
		MenuViewController *vc = (MenuViewController *)[segue.destinationViewController topViewController];
		vc.table = (Table *)sender;
	} else if ([[segue identifier] isEqualToString:@"editTable"]) {
		TableViewController *vc = (TableViewController *)[segue destinationViewController];
		vc.table = (Table *)sender;
	}
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)view;
        v.textLabel.textAlignment = NSTextAlignmentCenter;
        v.textLabel.textColor = [UIColor colorWithRed:0.203f green:0.444f blue:0.768f alpha:1.f];
        v.backgroundView.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.95f];
    }
}

#pragma mark - Alert View

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		Table *table = [[Table alloc] init];
		[table setName:[[alertView textFieldAtIndex:0] text]];
		
        [table save];
		
		[self reloadTables:nil];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [tables count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[tables objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"table";
	static NSString *descriptiveCellIdentifier = @"tableDescriptive";
    UITableViewCell *cell;
	
	Table *table = [[tables objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
	if (self.manageEnabled || table.group.orders.count == 0) {
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	} else {
		cell = [tableView dequeueReusableCellWithIdentifier:descriptiveCellIdentifier forIndexPath:indexPath];
	}
    
	cell.textLabel.text = [table name];
    
	if (!self.manageEnabled) {
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%d Orders", [table.group.orders count]];
	}
	
	cell.backgroundColor = [UIColor colorWithWhite:0.98f alpha:1.0f];
    cell.layer.borderWidth = 0.5f;
    cell.layer.borderColor = [UIColor colorWithWhite:0.9f alpha:1.0f].CGColor;
    [cell backgroundView].backgroundColor = [UIColor blackColor];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.manageEnabled) {
		[self performSegueWithIdentifier:@"editTable" sender:[[tables objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
		
		return;
	}
	
	Table *table = [[tables objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[[Storage getStorage] setActiveTable:table];
		return;
	}
	
	[self performSegueWithIdentifier:@"openBasket" sender:table];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [titles objectAtIndex:section];
}

@end
