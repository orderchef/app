//
//  OrdersViewController.m
//  OrderChef
//
//  Created by Matej Kramny on 27/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "OrdersViewController.h"
#import "Table.h"
#import "Item.h"
#import "MenuViewController.h"
#import "OrderItemViewController.h"
#import "TextareaCell.h"
#import "Employee.h"
#import "AppDelegate.h"
#import "OrderGroup.h"
#import "Order.h"
#import "OrderViewController.h"
#import "TextFieldCell.h"
#import <CoreLocation/CoreLocation.h>
#import <AFNetworking/AFNetworking.h>

@interface OrdersViewController () {
	UIActionSheet *printAndClearSheet;
	
	UITapGestureRecognizer *dismissPostcodeRecogniser;
	UITapGestureRecognizer *dismissCookingRecogniser;
	UITapGestureRecognizer *dismissDeliveryRecogniser;
	UITapGestureRecognizer *dismissTelephoneRecogniser;
	UITapGestureRecognizer *dismissCustomerNameRecogniser;
	
	UITapGestureRecognizer *tapToCancelPostcode;
	CLLocationManager *locationManager;
}

@end

@implementation OrdersViewController

@synthesize table, group;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self onLoad];
}

- (void)onLoad {
	if (table) {
		self.navigationItem.title = table.name;
		[self setRefreshControl:[[UIRefreshControl alloc] init]];
		[self.refreshControl addTarget:self action:@selector(refreshOrders:) forControlEvents:UIControlEventValueChanged];
	} else {
		self.navigationItem.title = @"";
	}
	
	UIBarButtonItem *printItem = [[UIBarButtonItem alloc] initWithTitle:@"\uf02f " style:UIBarButtonItemStylePlain target:self action:@selector(printButton:)];
	[printItem setTitleTextAttributes:@{
										NSFontAttributeName: [UIFont fontWithName:@"FontAwesome" size:24]
										} forState:UIControlStateNormal];
    [self.navigationItem setRightBarButtonItem:printItem animated:NO];
	
	[self refreshOrders:nil];
    [self reloadData];
	
	@try {
        [table removeObserver:self forKeyPath:@"group" context:nil];
    }
    @catch (NSException *exception) {}
	
	if (table) {
		[table addObserver:self forKeyPath:@"group" options:NSKeyValueObservingOptionNew context:nil];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"order"]) {
		OrderViewController *vc = (OrderViewController *)[segue destinationViewController];
		vc.order = (Order *)sender;
		vc.table = table;
		
		NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
		int row = (int)selectedIndexPath.row+1;
		if (selectedIndexPath.section == 1) {
			row = (int)group.orders.count;
		}
		
		vc.navigationItem.title = [NSString stringWithFormat:@"Order #%d", row];
	}
}

- (void)reloadData {
	if (table) group = table.group;
	[self.tableView reloadData];
}

- (void)refreshOrders:(id)sender {
	[self.table loadItems];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.tableView reloadData];
	if (table)
		[table addObserver:self forKeyPath:@"group" options:NSKeyValueObservingOptionNew context:nil];
	[[Storage getStorage] addObserver:self forKeyPath:@"activeTable" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
    @try {
        [table removeObserver:self forKeyPath:@"group" context:nil];
    }
    @catch (NSException *exception) {}
	@try {
        [[Storage getStorage] removeObserver:self forKeyPath:@"activeTable" context:nil];
    }
    @catch (NSException *exception) {}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"group"]) {
		[self reloadData];
        if ([self.refreshControl isRefreshing])
            [self.refreshControl endRefreshing];
	}
	if ([keyPath isEqualToString:@"activeTable"]) {
		self.table = [Storage getStorage].activeTable;
		self.group = table.group;
		
		[self onLoad];
	}
}

- (void)printButton:(id)sender {
	[group printBill];
	
	[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:@"Final Bill Printed" detail:nil hideAfter:0.5 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:self.navigationController.view];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (table.delivery) {
		return 4;
	}
	if (table.takeaway) {
		return 3;
	}
	
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	/*if (section == 0) {
		return 0;
	}*/
	
	if (section == 0) {
		return [group orders].count;
	}
	
	if (section == 1) {
		return 2;
	}
	
	if (section == 2 && table.takeaway) {
		return 2;
	}
	
	if (section == 2) {
		return 1;
	} if (section == 3) {
		return 4;
	}
	
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"basket";
	__unused static NSString *fieldIdentifier = @"text";
	
	/*
    if (indexPath.section == 0) {
		TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:fieldIdentifier forIndexPath:indexPath];
		if (!cell) {
			cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:fieldIdentifier];
		}
		
		cell.textField.text = @"";
		cell.textField.placeholder = @"Customer Name";
		
		return cell;
	}*/
	
	UITableViewCell *cell;
	if (indexPath.section == 2 || indexPath.section == 3) {
		NSString *identifier = @"postcode";
		if ((!table.takeaway && indexPath.section == 2) || (table.takeaway && indexPath.row == 0) || (indexPath.section == 3 && indexPath.row == 0)) {
			identifier = @"text";
		}
		
		cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
		if (!cell) {
			cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		}
	} else {
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.textAlignment = NSTextAlignmentLeft;
	}
	
	if (indexPath.section == 0) {
		cell.textLabel.font = [UIFont fontWithName:@"FontAwesome" size:18.f];
		
		Order *o = [group.orders objectAtIndex:indexPath.row];
		NSString *checkmark = @"\uf096\t";
		if (o.printed) {
			checkmark = @"\uf046\t";
		}
		cell.textLabel.text = [NSString stringWithFormat:@"%@#%d", checkmark, ((int)indexPath.row)+1];
		float total = 0;
		int totalq = 0;
		for (NSDictionary *item in o.items) {
			int q = [[item objectForKey:@"quantity"] intValue];
			float p = [[item objectForKey:@"price"] floatValue];
			total += q * p;
			totalq += q;
		}
		
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%d items, £%.2f", totalq, total];
	} else if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			cell.textLabel.text = @"Create New Order";
		} else {
			cell.textLabel.text = @"Print Final Bill";
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.textLabel.textAlignment = NSTextAlignmentCenter;
		}
		cell.detailTextLabel.text = nil;
	} else if (indexPath.section == 2 && table.delivery) {
		UITextField *field = [(TextFieldCell *)cell textField];
		[field setSpellCheckingType:UITextSpellCheckingTypeNo];
		[field setAutocapitalizationType:UITextAutocapitalizationTypeWords];
		[field setAutocorrectionType:UITextAutocorrectionTypeNo];
		[field setReturnKeyType:UIReturnKeyDone];
		[field setDelegate:self];
		
		[field setText:group.postcode];
		[field setPlaceholder:@"Address for Delivery"];
		[field addTarget:self action:@selector(dismissPostcode:) forControlEvents:UIControlEventEditingDidEnd];
		[field addTarget:self action:@selector(beganPostcode:) forControlEvents:UIControlEventEditingDidBegin];
	} else if (indexPath.section == 3 || (indexPath.section == 2 && table.takeaway)) {
		UITextField *field = [(TextFieldCell *)cell textField];
		[field setSpellCheckingType:UITextSpellCheckingTypeNo];
		[field setAutocapitalizationType:UITextAutocapitalizationTypeWords];
		[field setAutocorrectionType:UITextAutocorrectionTypeNo];
		[field setReturnKeyType:UIReturnKeyDone];
		[field setDelegate:self];
		
		if (indexPath.row == 0) {
			[field setText:group.customerName];
			[field setPlaceholder:@"Customer Name"];
			[field setClearButtonMode:UITextFieldViewModeWhileEditing];
			[field setKeyboardType:UIKeyboardTypeDefault];
			[field addTarget:self action:@selector(dismissCustomerName:) forControlEvents:UIControlEventEditingDidEnd];
			[field addTarget:self action:@selector(beganCustomerName:) forControlEvents:UIControlEventEditingDidBegin];
		} else if (indexPath.row == 1) {
			[[(TextFieldCell *)cell label] setText:@"Telephone:"];
			[field setText:group.telephone];
			[field setPlaceholder:@"Number"];
			[field setClearButtonMode:UITextFieldViewModeNever];
			[field setKeyboardType:UIKeyboardTypePhonePad];
			[field addTarget:self action:@selector(dismissTelephone:) forControlEvents:UIControlEventEditingDidEnd];
			[field addTarget:self action:@selector(beganTelephone:) forControlEvents:UIControlEventEditingDidBegin];
		} else if (indexPath.row == 2) {
			[[(TextFieldCell *)cell label] setText:@"Deliver At:"];
			[field setText:group.deliveryTime];
			[field setClearButtonMode:UITextFieldViewModeWhileEditing];
			[field setPlaceholder:@"7:40 pm (time)"];
			[field setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
			[field addTarget:self action:@selector(dismissDeliveryTime:) forControlEvents:UIControlEventEditingDidEnd];
			[field addTarget:self action:@selector(beganDeliveryTime:) forControlEvents:UIControlEventEditingDidBegin];
		} else if (indexPath.row == 3) {
			[[(TextFieldCell *)cell label] setText:@"Start Cooking At:"];
			[field setText:group.cookingTime];
			[field setClearButtonMode:UITextFieldViewModeWhileEditing];
			[field setPlaceholder:@"7:10 pm (time)"];
			[field setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
			[field addTarget:self action:@selector(dismissCookingTime:) forControlEvents:UIControlEventEditingDidEnd];
			[field addTarget:self action:@selector(beganCookingTime:) forControlEvents:UIControlEventEditingDidBegin];
		}
	}
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Order *o;
	//if (indexPath.section == 0) return;
	
	if (indexPath.section == 1) {
		if (indexPath.row == 1) {
			// clear
			if (!printAndClearSheet) {
				printAndClearSheet = [[UIActionSheet alloc] initWithTitle:@"Print and Clear All Orders?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Just Print", @"Print & Clear Table", nil];
			}
			[printAndClearSheet showInView:self.navigationController.view];
			
			return;
		}
		
		o = [[Order alloc] init];
		o.group = group;
		[o save];
		
		NSMutableArray *orders = [group.orders mutableCopy];
		[orders addObject:o];
		group.orders = orders;
		
		[group setOrders:orders];
	} else if (indexPath.section == 0) {
		o = [group.orders objectAtIndex:indexPath.row];
	} else if (indexPath.section == 2 || indexPath.section == 3) {
		TextFieldCell *cell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:indexPath];
		[cell.textField becomeFirstResponder];
		
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		
		return;
	}
	
	[self performSegueWithIdentifier:@"order" sender:o];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Orders";
	}
	if (section == 2 && table.delivery) {
		return @"Delivery Information";
	}
	if (section == 2 && table.takeaway) {
		return @"Customer Details";
	}
	
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 1) {
		return @"Print Final Bill button will only print to Receipt Printers. Cleared Orders are Viewable from the Admin Reports Section.";
	}
	if (section == 2 && group.postcodeDistance.length > 0) {
		return [@"Distance to target: " stringByAppendingString:group.postcodeDistance];
	}
	
	return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0)
		return YES;
	
	return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section != 0 || editingStyle != UITableViewCellEditingStyleDelete) {
		return;
	}
	
	Order *order = [group.orders objectAtIndex:indexPath.row];
	[order remove];
	
	NSMutableArray *mutableOrders = [group.orders mutableCopy];
	[mutableOrders removeObjectAtIndex:indexPath.row];
	[group setOrders:[mutableOrders copy]];
	
	[tableView reloadData];
	[self setEditing:false];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex < 2) {
		[group printBill];
		
		NSString *msg = @"Final Bill Printed";
		if (buttonIndex == 1) {
			msg = @"Final Bill Printed & Cleared";
			[group clear];
		}
		
		[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:msg detail:@"Printed to Receipt Printer only" hideAfter:0.5 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:self.view];
		[self refreshOrders:nil];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - Text Fields
#pragma mark Postcode

- (void)beganPostcode:(id)sender {
	dismissPostcodeRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPostcode:)];
	[dismissPostcodeRecogniser setCancelsTouchesInView:YES];
	[self.tableView addGestureRecognizer:dismissPostcodeRecogniser];
}

- (void)dismissPostcode:(id)sender {
	@try {
		[self.tableView removeGestureRecognizer:dismissPostcodeRecogniser];
	} @catch (NSException *e) {}
	dismissPostcodeRecogniser = nil;
	
	TextFieldCell *cell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
	[cell.textField resignFirstResponder];
	group.postcode = cell.textField.text;
	
	if (group.postcode.length > 0) {
		tapToCancelPostcode = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelPostcodeLookup:)];
		[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:@"Getting Current Location" detail:@"Tap to Cancel" hideAfter:0 showAnimated:YES hideAnimated:NO hide:NO tapRecognizer:tapToCancelPostcode toView:self.navigationController.view];
		
		locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
		locationManager.distanceFilter = kCLDistanceFilterNone;
		locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		[locationManager startUpdatingLocation];
	} else {
		group.postcode = @"";
		group.postcodeDistance = @"";
		[group save];
		
		[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	CLLocation *location = [locations lastObject];
	[locationManager stopUpdatingLocation];
	
	[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:@"Calculating Distance" detail:@"Tap to Cancel" hideAfter:0 showAnimated:YES hideAnimated:NO hide:NO tapRecognizer:tapToCancelPostcode toView:self.navigationController.view];
	
	AFHTTPRequestOperationManager *request = [AFHTTPRequestOperationManager manager];
	[request GET:[[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/distancematrix/json?origins=%f,%f&destinations=%@&units=imperial&sensor=false", location.coordinate.latitude, location.coordinate.longitude, [group.postcode stringByReplacingOccurrencesOfString:@" " withString:@"+"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *json) {
		NSLog(@"%@", json);
		if ([[json objectForKey:@"status"] isEqualToString:@"OK"]) {
			//YAY
			NSDictionary *elements = [[[[json objectForKey:@"rows"] objectAtIndex:0] objectForKey:@"elements"] objectAtIndex:0];
			if (![[elements objectForKey:@"status"] isEqualToString:@"OK"]) {
				[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:@"Address Not Found" detail:nil hideAfter:0.5 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:self.navigationController.view];
				return;
			}
			
			NSString *distance = [[elements objectForKey:@"distance"] objectForKey:@"text"];
			NSString *time = [[elements objectForKey:@"duration"] objectForKey:@"text"];
			NSString *formatted = [[NSString alloc] initWithFormat:@"%@, %@", distance, time];
			[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:formatted detail:nil hideAfter:1 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:self.navigationController.view];
			group.postcodeDistance = formatted;
			
			[group save];
			
			[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
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

#pragma mark Cooking Time

- (void)beganCookingTime:(id)sender {
	dismissCookingRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissCookingTime:)];
	[dismissCookingRecogniser setCancelsTouchesInView:YES];
	[self.tableView addGestureRecognizer:dismissCookingRecogniser];
}

- (void)dismissCookingTime:(id)sender {
	@try {
		[self.tableView removeGestureRecognizer:dismissCookingRecogniser];
	} @catch (NSException *e) {}
	dismissCookingRecogniser = nil;
	
	TextFieldCell *cell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:3]];
	[cell.textField resignFirstResponder];
	group.cookingTime = cell.textField.text;
	
	[group save];
}

#pragma mark Delivery Time

- (void)beganDeliveryTime:(id)sender {
	dismissDeliveryRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDeliveryTime:)];
	[dismissDeliveryRecogniser setCancelsTouchesInView:YES];
	[self.tableView addGestureRecognizer:dismissDeliveryRecogniser];
}

- (void)dismissDeliveryTime:(id)sender {
	@try {
		[self.tableView removeGestureRecognizer:dismissDeliveryRecogniser];
	} @catch (NSException *e) {}
	dismissDeliveryRecogniser = nil;
	
	TextFieldCell *cell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:3]];
	[cell.textField resignFirstResponder];
	group.deliveryTime = cell.textField.text;
	
	[group save];
}

#pragma mark Telephone

- (void)beganTelephone:(id)sender {
	dismissTelephoneRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTelephone:)];
	[dismissTelephoneRecogniser setCancelsTouchesInView:YES];
	[self.tableView addGestureRecognizer:dismissTelephoneRecogniser];
}

- (void)dismissTelephone:(id)sender {
	@try {
		[self.tableView removeGestureRecognizer:dismissTelephoneRecogniser];
	} @catch (NSException *e) {}
	dismissTelephoneRecogniser = nil;
	
	int section = 3;
	if (table.takeaway) {
		section = 2;
	}
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:section];
	TextFieldCell *cell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	[cell.textField resignFirstResponder];
	group.telephone = cell.textField.text;
	
	[group save];
}

#pragma mark Cusotmer Name

- (void)beganCustomerName:(id)sender {
	dismissCustomerNameRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissCustomerName:)];
	[dismissCustomerNameRecogniser setCancelsTouchesInView:YES];
	[self.tableView addGestureRecognizer:dismissCustomerNameRecogniser];
}

- (void)dismissCustomerName:(id)sender {
	@try {
		[self.tableView removeGestureRecognizer:dismissCustomerNameRecogniser];
	} @catch (NSException *e) {}
	dismissCustomerNameRecogniser = nil;
	
	int section = 3;
	if (table.takeaway) {
		section = 2;
	}
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
	TextFieldCell *cell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	[cell.textField resignFirstResponder];
	group.customerName = cell.textField.text;
	
	[group save];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	
	return YES;
}

@end
