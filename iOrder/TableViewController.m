//
//  TableViewController.m
//  iOrder
//
//  Created by Matej Kramny on 27/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "TableViewController.h"
#import "AppDelegate.h"
#import "Table.h"
#import "BasketTableViewController.h"
#import "MenuViewController.h"
#import "Storage.h"
#import "Connection.h"
#import "EditTableViewController.h"
#import <LTHPasscodeViewController.h>

@interface TableViewController () {
    NSArray *tables;
}

@end

@implementation TableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(toggleEdit:)]];
    
    [[Storage getStorage] addObserver:self forKeyPath:@"tables" options:NSKeyValueObservingOptionNew context:nil];
    
    [self setRefreshControl:[[UIRefreshControl alloc] init]];
    [self.refreshControl addTarget:self action:@selector(reloadTables:) forControlEvents:UIControlEventValueChanged];
    
	[self setEditing:NO animated:YES];
	[self.tableView setAllowsSelectionDuringEditing:YES];
	
    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self reloadData];
}

- (void)dealloc {
    @try {
        [[Storage getStorage] addObserver:self forKeyPath:@"tables" options:NSKeyValueObservingOptionNew context:nil];
    } @catch (NSException *ex) {}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"tables"]) {
        [self reloadData];
        if ([self.refreshControl isRefreshing]) {
            [self.refreshControl endRefreshing];
        }
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	if (editing) {
		[self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Add Table" style:UIBarButtonItemStylePlain target:self action:@selector(addTable:)] animated:animated];
		[self.navigationItem.rightBarButtonItem setTitle:@"Done"];
	} else {
		[self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Manager" style:UIBarButtonItemStylePlain target:self action:@selector(openManager:)] animated:animated];
		[self.navigationItem.rightBarButtonItem setTitle:@"Edit"];
	}
	
	[super setEditing:editing animated:animated];
}

- (void)toggleEdit:(id)sender {
	[self setEditing:![self.tableView isEditing] animated:YES];
}

- (void)reloadTables:(id)sender {
    [[[Connection getConnection] socket] sendEvent:@"get.tables" withData:nil];
    [self.refreshControl beginRefreshing];
}

- (void)reloadData {
    Storage *storage = [Storage getStorage];
    tables = [storage tables];
    
    [self.tableView reloadData];
}

- (void)addTable:(id)sender {
	UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Enter Table name" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
	[view setAlertViewStyle:UIAlertViewStylePlainTextInput];
	
	[view show];
}

- (void)openManager:(id)sender {
	[self performSegueWithIdentifier:@"openManager" sender:nil];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([tableView isEditing]) {
		return UITableViewCellEditingStyleDelete;
	}
	
	return UITableViewCellEditingStyleNone;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		Table *table = [tables objectAtIndex:indexPath.row];
		[table deleteTable];
		
		[self setEditing:NO animated:YES];
		
		// Allows time for the table to animate away, then refreshes the table..
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.8f * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[self.refreshControl beginRefreshing];
			[self reloadTables:nil];
		});
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tables count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"table";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [[tables objectAtIndex:indexPath.row] name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([tableView isEditing]) {
		[self performSegueWithIdentifier:@"editTable" sender:[tables objectAtIndex:indexPath.row]];
		[self setEditing:NO animated:YES];
		return;
	}
	
	[self performSegueWithIdentifier:@"openBasket" sender:[tables objectAtIndex:indexPath.row]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"openBasket"]) {
		BasketTableViewController *vc = (BasketTableViewController *)[segue destinationViewController];
		vc.table = (Table *)sender;
	} else if ([[segue identifier] isEqualToString:@"openMenu"]) {
		MenuViewController *vc = (MenuViewController *)[segue.destinationViewController topViewController];
		vc.table = (Table *)sender;
	} else if ([[segue identifier] isEqualToString:@"editTable"]) {
		EditTableViewController *vc = (EditTableViewController *)[segue destinationViewController];
		vc.table = (Table *)sender;
	}
}

@end
