//
//  BasketViewController.m
//  iOrder
//
//  Created by Matej Kramny on 02/11/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "OrderViewController.h"
#import "Table.h"
#import "Item.h"
#import "MenuViewController.h"
#import "OrderItemViewController.h"
#import "TextareaCell.h"
#import "TextFieldCell.h"
#import "Employee.h"
#import "AppDelegate.h"
#import "OrderGroup.h"
#import "Order.h"
#import <CoreLocation/CoreLocation.h>
#import <AFNetworking/AFNetworking.h>

@interface OrderViewController () {
    UITapGestureRecognizer *dismissKeyboardGesture;
    bool keyboardIsOpen;
	UIActionSheet *sheet;
	UIBarButtonItem *printItem;
	bool confirmedReprint;
	
	bool showsDoneToDismiss;
	
	UITapGestureRecognizer *tapToCancelPostcode;
	CLLocationManager *locationManager;
}

@end

@implementation OrderViewController

@synthesize table;
@synthesize order;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	showsDoneToDismiss = false;
    keyboardIsOpen = false;
    confirmedReprint = false;
	
	printItem = [[UIBarButtonItem alloc] initWithTitle:@"\uf02f " style:UIBarButtonItemStylePlain target:self action:@selector(printOrder:)];
	[printItem setTitleTextAttributes:@{
										NSFontAttributeName: [UIFont fontWithName:@"FontAwesome" size:24]
										} forState:UIControlStateNormal];
    
	[self setRefreshControl:[[UIRefreshControl alloc] init]];
    [self.refreshControl addTarget:self action:@selector(refreshBasket:) forControlEvents:UIControlEventValueChanged];
    
    [self reloadData];
	
	//[self.navigationItem setTitle:[order.created description]];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self reloadData];
	[order addObserver:self forKeyPath:@"items" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	if (showsDoneToDismiss) {
		[self dismissPostcode:nil];
	}
	
    @try {
        [order removeObserver:self forKeyPath:@"items" context:nil];
    }
    @catch (NSException *exception) {}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"items"]) {
        [self reloadData];
        if ([self.refreshControl isRefreshing])
            [self.refreshControl endRefreshing];
    }
}

- (void)refreshBasket:(id)sender {
    [self.order.group getOrders];
}

- (void)reloadData {
	[self.tableView reloadData];
	
	[self updateButtons];
}

- (void)updateButtons {
	if (order.items.count > 0) {
		if (showsDoneToDismiss) {
			[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissPostcode:)] animated:YES];
		} else {
			[self.navigationItem setRightBarButtonItem:printItem animated:true];
		}
	} else {
		[self.navigationItem setRightBarButtonItem:nil animated:true];
	}
}

- (void)openMenu:(id)sender {
	[sheet showInView:self.view];
}

- (void)printOrder:(id)sender {
	if (order.printed && !confirmedReprint) {
		if (!sheet) {
			sheet = [[UIActionSheet alloc] initWithTitle:[@"Order was printed at " stringByAppendingString:[order.created description]] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Print Again", nil];
		}
		
		[sheet showInView:self.view];
		return;
	}
	
    [order print];
	
	[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:@"Order Printed" detail:nil hideAfter:0.5 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:self.view];
	
	confirmedReprint = false;
	[self reloadData];
}

- (void)startedPostcodeEditing:(id)sender {
	showsDoneToDismiss = YES;
	[self updateButtons];
}

- (void)dismissPostcode:(id)sender {
	showsDoneToDismiss = NO;
	[self updateButtons];
	
	TextFieldCell *cell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:4]];
	[cell.textField resignFirstResponder];
	order.postcode = cell.textField.text;
	
	if (order.postcode) {
		tapToCancelPostcode = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelPostcodeLookup:)];
		[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:@"Getting Current Location" detail:@"Tap to Cancel" hideAfter:0 showAnimated:YES hideAnimated:NO hide:NO tapRecognizer:tapToCancelPostcode toView:self.navigationController.view];
		
		locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
		locationManager.distanceFilter = kCLDistanceFilterNone;
		locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		[locationManager startUpdatingLocation];
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	CLLocation *location = [locations lastObject];
	[locationManager stopUpdatingLocation];
	
	[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:@"Calculating Distance" detail:@"Tap to Cancel" hideAfter:0 showAnimated:YES hideAnimated:NO hide:NO tapRecognizer:tapToCancelPostcode toView:self.navigationController.view];
	
	AFHTTPRequestOperationManager *request = [AFHTTPRequestOperationManager manager];
	[request GET:[[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/distancematrix/json?origins=%f,%f&destinations=%@&sensor=false", location.coordinate.latitude, location.coordinate.longitude, order.postcode] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *json) {
		if ([[json objectForKey:@"status"] isEqualToString:@"OK"]) {
			//YAY
			NSDictionary *elements = [[[[json objectForKey:@"rows"] objectAtIndex:0] objectForKey:@"elements"] objectAtIndex:0];
			if (![[elements objectForKey:@"status"] isEqualToString:@"OK"]) {
				return;
			}
			
			NSString *distance = [[elements objectForKey:@"distance"] objectForKey:@"text"];
			NSString *time = [[elements objectForKey:@"duration"] objectForKey:@"text"];
			NSString *formatted = [[NSString alloc] initWithFormat:@"%@, %@", distance, time];
			[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:formatted detail:nil hideAfter:1 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:self.navigationController.view];
			order.postcodeDistance = formatted;
			
			[order save];
			
			[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationFade];
		} else {
			[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:@"Failed to get Location" detail:nil hideAfter:0.5 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:self.navigationController.view];
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:@"Failed to get Location" detail:nil hideAfter:0.5 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:self.navigationController.view];
	}];
}

- (void)cancelPostcodeLookup:(id)sender {
	[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:@"Cancelled Postcode Location" detail:nil hideAfter:0.5 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:self.navigationController.view];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	int sections = 1;
	if ([order.items count] > 0) {
		sections = 4;
		
		if (table.delivery) sections++;
	}
	
	return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return [[order items] count];
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
    } else if (indexPath.section == 3) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"notes" forIndexPath:indexPath];
        if (!cell) {
            cell = [[TextareaCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notes"];
        }
    } else if (indexPath.section == 4) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"postcode" forIndexPath:indexPath];
		if (!cell) {
			cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"postcode"];
		}
	}
    
    if (indexPath.section == 0) {
		cell.textLabel.font = [UIFont fontWithName:@"FontAwesome" size:cell.textLabel.font.pointSize];
        cell.textLabel.text = @"\uf07a Order more items";
        cell.detailTextLabel.text = @"";
    } else if (indexPath.section == 1) {
        NSDictionary *item = [[order items] objectAtIndex:indexPath.row];
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
        [[(TextareaCell *)cell textField] setText:order.notes];
        [[(TextareaCell *)cell textField] setDelegate:(TextareaCell<UITextViewDelegate> *)cell];
        [(TextareaCell *)cell setDelegate:self];
    } else if (indexPath.section == 4) {
		UITextField *field = [(TextFieldCell *)cell textField];
		[field setText:order.postcode];
		[field setPlaceholder:@"Postcode for Delivery"];
		[field addTarget:self action:@selector(startedPostcodeEditing:) forControlEvents:UIControlEventEditingDidBegin];
		[field setSpellCheckingType:UITextSpellCheckingTypeNo];
		[field setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
		[field setAutocorrectionType:UITextAutocorrectionTypeNo];
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (showsDoneToDismiss) {
		[self dismissPostcode:nil];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		return;
	}
	
    if (indexPath.section == 0) {
        [self performSegueWithIdentifier:@"openMenu" sender:nil];
    } else if (indexPath.section == 1) {
        [self performSegueWithIdentifier:@"openBasketItem" sender:indexPath];
    } else if (indexPath.section == 3) {
		TextareaCell *cell = (TextareaCell *)[tableView cellForRowAtIndexPath:indexPath];
		[[cell textField] becomeFirstResponder];
		
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
		return;
	}
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"openMenu"]) {
        MenuViewController *vc = (MenuViewController *)segue.destinationViewController;
		vc.table = table;
		vc.activeOrder = order;
    } else if ([[segue identifier] isEqualToString:@"openBasketItem"]) {
		OrderItemViewController *vc = (OrderItemViewController *)segue.destinationViewController;
		NSDictionary *item = [[order items] objectAtIndex:((NSIndexPath *)sender).row];
		vc.item = item;
		vc.table = table;
		vc.order = order;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 1:
            return @"Items in Basket";
        case 3:
            return @"Notes for Order";
		case 4:
			return @"Delivery Postcode";
        default:
            return @"";
    }
    return section == 1 ? @"Items" : @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 0 && order.printed) {
		return [@"This order was printed at " stringByAppendingString:[order.printedAt description]];
	} else if (section == 0 && order.items.count == 0) {
		return @"This is a new order. Add some items from the menu.";
	}
	
    if (section == 2) {
        float total = 0.f;
        for (NSDictionary *item in [order items]) {
            Item *it = [item objectForKey:@"item"];
            total += [[item objectForKey:@"quantity"] intValue] * [it.price floatValue];
        }
        
        return [@"---- Total £" stringByAppendingFormat:@"%.2f ----", total];
    }
	if (section == 4) {
		return order.postcodeDistance;
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
	order.notes = [cell.textField text];
    [order save];
    
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
			confirmedReprint = true;
			[self printOrder:nil];
			break;
	}
}

@end
