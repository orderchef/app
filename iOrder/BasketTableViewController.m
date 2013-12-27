//
//  BasketViewController.m
//  iOrder
//
//  Created by Matej Kramny on 02/11/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "BasketTableViewController.h"
#import "Table.h"
#import "Item.h"
#import "MenuViewController.h"
#import "BasketItemViewController.h"
#import "TextareaCell.h"
#import "Employee.h"
#import "AppDelegate.h"
#import "OrderGroup.h"
#import "Order.h"

@interface BasketTableViewController () {
    UITapGestureRecognizer *dismissKeyboardGesture;
    bool keyboardIsOpen;
	UIActionSheet *sheet;
	UIBarButtonItem *printItem;
}

@end

@implementation BasketTableViewController

@synthesize table;
@synthesize activeOrder;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    keyboardIsOpen = false;
    
    [table loadItems];
    
	[self setRefreshControl:[[UIRefreshControl alloc] init]];
    [self.refreshControl addTarget:self action:@selector(refreshBasket:) forControlEvents:UIControlEventValueChanged];
    
    [self reloadData];
	
	[self.navigationItem setTitle:[table name]];
	
	printItem = [[UIBarButtonItem alloc] initWithTitle:@"\uf02f " style:UIBarButtonItemStylePlain target:self action:@selector(printOrder:)];
	[printItem setTitleTextAttributes:@{
										 NSFontAttributeName: [UIFont fontWithName:@"FontAwesome" size:24]
										 } forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[table addObserver:self forKeyPath:@"group" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
    @try {
        [table removeObserver:self forKeyPath:@"group" context:nil];
    }
    @catch (NSException *exception) {}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"group"]) {
        [self reloadData];
        if ([self.refreshControl isRefreshing])
            [self.refreshControl endRefreshing];
    }
}

- (void)refreshBasket:(id)sender {
    [self.table loadItems];
}

- (void)reloadData {
	[self.tableView reloadData];
	
	if (!activeOrder) {
		if (table.group.orders.count == 0) {
			[table.group setOrders:@[[[Order alloc] init]]];
		}
		
		activeOrder = [table.group.orders objectAtIndex:0];
	}
	
	/*
	if (table.items.count > 0) {
		[self.navigationItem setRightBarButtonItem:printItem animated:true];
	} else {
		[self.navigationItem setRightBarButtonItem:nil animated:true];
	}*/
}

- (void)openMenu:(id)sender {
	[sheet showInView:self.view];
}

- (void)clear:(id)sender {
    /*[table clearTable];
    [table setItems:@[]];
	[table setNotes:@""];
	[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:[table.name stringByAppendingString:@" Printing.."] detail:Nil hideAfter:0.5 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:self.parentViewController.view];*/
	[self reloadData];
}
- (void)printOrder:(id)sender {
    [table sendToKitchen];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[activeOrder items] count] > 0 ? 4 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return [[activeOrder items] count];
    }
    if (section == 2) {
        return 0;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"basket";
    UITableViewCell *cell;
    
    if (indexPath.section < 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"notes" forIndexPath:indexPath];
        if (!cell) {
            cell = [[TextareaCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notes"];
        }
    }
    
    if (indexPath.section == 0) {
		cell.textLabel.font = [UIFont fontWithName:@"FontAwesome" size:cell.textLabel.font.pointSize];
        cell.textLabel.text = @"\uf07a Order more items";
        cell.detailTextLabel.text = @"";
    } else if (indexPath.section == 1) {
        NSDictionary *item = [[activeOrder items] objectAtIndex:indexPath.row];
        Item *it = [item objectForKey:@"item"];
        int quantity = [[item objectForKey:@"quantity"] intValue];
        float total = quantity * [it.price floatValue];
        
        cell.textLabel.text = it.name;
        if (quantity > 1) {
            cell.textLabel.text = [it.name stringByAppendingFormat:@" (%d)", quantity];
        }
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"£%.2f", total];
    } else if (indexPath.section == 3) {
        // notes
        //[[(TextareaCell *)cell textField] setText:table.notes];
        [[(TextareaCell *)cell textField] setDelegate:(TextareaCell<UITextViewDelegate> *)cell];
        [(TextareaCell *)cell setDelegate:self];
    }
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self performSegueWithIdentifier:@"openMenu" sender:nil];
    } else if (indexPath.section == 1) {
        [self performSegueWithIdentifier:@"openBasketItem" sender:indexPath];
    } else if (indexPath.section == 3) {
		TextareaCell *cell = (TextareaCell *)[tableView cellForRowAtIndexPath:indexPath];
		[[cell textField] becomeFirstResponder];
	}
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"openMenu"]) {
        MenuViewController *vc = (MenuViewController *)segue.destinationViewController;
		vc.table = table;
		vc.activeOrder = activeOrder;
    } else if ([[segue identifier] isEqualToString:@"openBasketItem"]) {
		BasketItemViewController *vc = (BasketItemViewController *)segue.destinationViewController;
		NSDictionary *item = [[table.group orders] objectAtIndex:((NSIndexPath *)sender).row];
		vc.item = item;
		vc.table = table;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 1:
            return @"Items in Basket";
        case 3:
            return @"Notes for Order";
        default:
            return @"";
    }
    return section == 1 ? @"Items in basket" : @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 2) {
        float total = 0.f;
        for (NSDictionary *item in [activeOrder items]) {
            Item *it = [item objectForKey:@"item"];
            total += [[item objectForKey:@"quantity"] intValue] * [it.price floatValue];
        }
        
        return [@"---- Total £" stringByAppendingFormat:@"%.2f ----", total];
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
	if (section == 2 && [view isKindOfClass:[UITableViewHeaderFooterView class]]) {
		UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)view;
		v.textLabel.textAlignment = NSTextAlignmentCenter;
		v.textLabel.textColor = [UIColor blackColor];
		v.textLabel.font = [UIFont systemFontOfSize:16.f];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 3) {
        return 100.f;
    }
    
    return 44.f;
}

#pragma mark - TextfieldDelegate methods

- (void)dismissKeyboard:(id)sender {
    TextareaCell *cell = (TextareaCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    [[cell textField] resignFirstResponder];
}

- (void)textFieldDidBeginEditing {
    //[self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height  - 216 + self.toolbar.frame.size.height)];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    dismissKeyboardGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    dismissKeyboardGesture.cancelsTouchesInView = YES;
    
    [self.tableView addGestureRecognizer:dismissKeyboardGesture];
    
    keyboardIsOpen = true;
}

- (void)textFieldDidEndEditing {
    //[self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height  + 216 - self.toolbar.frame.size.height)];
    
    keyboardIsOpen = false;
    
    TextareaCell *cell = (TextareaCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
	activeOrder.notes = [cell.textField text];
#warning TODO activeOrder save
    //[activeOrder save];
    
    @try {
        [self.tableView removeGestureRecognizer:dismissKeyboardGesture];
    }
    @catch (NSException *exception) {}
    @finally {
        dismissKeyboardGesture = nil;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (keyboardIsOpen) {
        [self dismissKeyboard:nil];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
			[self printOrder:nil];
			break;
		case 1:
			[self clear:nil];
	}
}

@end
