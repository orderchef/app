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
#import "TablesViewController.h"
#import "DatePickerTableViewCell.h"
#import "DiscountsViewController.h"
#import "PrintReceiptViewController.h"

@interface OrdersViewController () {
	UITapGestureRecognizer *dismissPostcodeRecogniser;
	UITapGestureRecognizer *dismissCookingRecogniser;
	UITapGestureRecognizer *dismissDeliveryRecogniser;
	UITapGestureRecognizer *dismissTelephoneRecogniser;
	UITapGestureRecognizer *dismissCustomerNameRecogniser;
	
	UITapGestureRecognizer *tapToCancelPostcode;
	CLLocationManager *locationManager;
	
	bool showsDatePicker;
	
	UIPopoverController *popover;
}

@end

@interface OrdersViewController (PopoverDelegate) <UIPopoverControllerDelegate>

@end

@implementation OrdersViewController

@synthesize table, group;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	showsDatePicker = false;
	[self onLoad];
	[[Storage getStorage] addObserver:self forKeyPath:@"activeTable" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc {
	@try {
        [[Storage getStorage] removeObserver:self forKeyPath:@"activeTable" context:nil];
    }
    @catch (NSException *exception) {}
	@try {
        [table removeObserver:self forKeyPath:@"group" context:nil];
    }
    @catch (NSException *exception) {}
}

- (void)onLoad {
	if (table) {
		self.navigationItem.title = table.name;
		[self setRefreshControl:[[UIRefreshControl alloc] init]];
		[self.refreshControl addTarget:self action:@selector(refreshOrders:) forControlEvents:UIControlEventValueChanged];
	} else {
		self.navigationItem.title = @"";
		if (group.table) {
			self.navigationItem.title = group.table.name;
		}
	}
	
	// Animates the table when refreshing..
	CATransition *transition = [CATransition animation];
	transition.type = kCATransitionFade;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition.duration = 0.1;
	[self.tableView.layer addAnimation:transition forKey:@"UITableViewReloadDataAnimationKey"];
	
	showsDatePicker = false;
	
	[self refreshOrders:nil];
    [self reloadData];
	
	@try {
        [table removeObserver:self forKeyPath:@"group" context:nil];
    }
    @catch (NSException *exception) {}
	
	if (table) {
		[table addObserver:self forKeyPath:@"group" options:NSKeyValueObservingOptionNew context:nil];
	}
	
	if (!table) {
		self.table = group.table;
		[self.tableView reloadData];
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
	} else if ([segue.identifier isEqualToString:@"openDiscounts"]) {
		DiscountsViewController *vc = [[segue.destinationViewController viewControllers] objectAtIndex:0];
		vc.group = group;
	} else if ([segue.identifier isEqualToString:@"printBill"]) {
		PrintReceiptViewController *vc = [[segue.destinationViewController viewControllers] objectAtIndex:0];
		vc.group = group;
		vc.parentView = self;
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
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	if (showsDatePicker) {
		[self.group save];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"group"]) {
		[self reloadData];
        if ([self.refreshControl isRefreshing])
            [self.refreshControl endRefreshing];
		
		table.customerName = group.customerName;
		table.orders = (int)group.orders.count;
		
		[self reloadParentView];
	}
	if ([keyPath isEqualToString:@"activeTable"] && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		self.table = [Storage getStorage].activeTable;
		self.group = table.group;
		
		[self onLoad];
	}
}

- (void)printButton:(id)sender {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		UINavigationController *navvc = [[self.navigationController storyboard] instantiateViewControllerWithIdentifier:@"printReceipt"];
		PrintReceiptViewController *vc = (PrintReceiptViewController *)[[navvc viewControllers] objectAtIndex:0];
		vc.group = self.group;
		vc.parentView = self;
		
		popover = [[UIPopoverController alloc] initWithContentViewController:navvc];
		vc.popover = popover;
		
		popover.popoverContentSize = CGSizeMake(360, 416);
		UITableViewCell *cell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:(NSIndexPath *)sender];
		
		[popover presentPopoverFromRect:cell.bounds inView:cell.contentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		popover.delegate = self;
		
		return;
	} else {
		[self performSegueWithIdentifier:@"printBill" sender:nil];
	}
}

- (void)reloadParentView {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && self.splitViewController && self.group.cleared == false) {
		UINavigationController *navVC = [[[self splitViewController] viewControllers] objectAtIndex:0];
		if (navVC) {
			TablesViewController *tablesVC = [[navVC viewControllers] objectAtIndex:0];
			[tablesVC reloadData];
		}
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (table.delivery) {
		return 6;
	}
	
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
		return [group orders].count;
	}
	
	if (section == 1) {
		return 2;
	}
	
	if (table.delivery) {
		if (section == 2) {
			return 1;
		}
		if (section == 3) {
			if (showsDatePicker) return 5;
			return 4;
		}
		section--;
	}
	
	if (table.takeaway && section == 2) {
		return 3;
	}
	
	if (section == 2) {
		return 1;
	}
	
	if (section == 3) {
		// Discounts
		return 1;
	}
	
	if (section == 4) {
		return 0;
	}
	
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"basket";
	__unused static NSString *fieldIdentifier = @"text";
	__unused static NSString *basicCellIdentifier = @"basic";
	
	UITableViewCell *cell;
	if ((!table.delivery && indexPath.section == 3) || indexPath.section == 4) {
		cell = [tableView dequeueReusableCellWithIdentifier:basicCellIdentifier forIndexPath:indexPath];
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.textAlignment = NSTextAlignmentLeft;
	} else if (indexPath.section == 2 || indexPath.section == 3) {
		NSString *identifier = @"postcode";
		if (indexPath.row == 0 && (indexPath.section == 2 || indexPath.section == 3)) {
			identifier = @"text";
		}
		
		if (indexPath.row == 3 && table.delivery && showsDatePicker) {
			cell = [tableView dequeueReusableCellWithIdentifier:@"datePicker" forIndexPath:indexPath];
			if (!cell) {
				cell = [[DatePickerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"datePicker"];
			}
		} else {
			cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
			if (!cell) {
				cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
			}
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
			cell.textLabel.textAlignment = NSTextAlignmentCenter;
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		cell.detailTextLabel.text = nil;
	} else if (indexPath.section == 2 && table.delivery) {
		UITextField *field = [(TextFieldCell *)cell textField];
		[field setSpellCheckingType:UITextSpellCheckingTypeNo];
		[field setAutocapitalizationType:UITextAutocapitalizationTypeWords];
		[field setAutocorrectionType:UITextAutocorrectionTypeNo];
		[field setReturnKeyType:UIReturnKeyDone];
		
		[field removeTarget:nil action:nil forControlEvents:UIControlEventAllEditingEvents];
		[field setDelegate:self];
		
		[field setText:group.postcode];
		[field setPlaceholder:@"Address for Delivery"];
		[field addTarget:self action:@selector(dismissPostcode:) forControlEvents:UIControlEventEditingDidEnd];
		[field addTarget:self action:@selector(beganPostcode:) forControlEvents:UIControlEventEditingDidBegin];
	} else if (indexPath.section == 2 || (indexPath.section == 3 && table.delivery)) {
		if (indexPath.row == 3 && table.delivery && showsDatePicker) {
			DatePickerTableViewCell *_cell = (DatePickerTableViewCell *)cell;
			[_cell.datePicker setDatePickerMode:UIDatePickerModeTime];
			[_cell.datePicker addTarget:self action:@selector(deliveryDateChanged:) forControlEvents:UIControlEventValueChanged];
			
			NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
			timeFormatter.dateFormat = @"hh:mm a";
			NSDate *date = [timeFormatter dateFromString:group.deliveryTime];
			if (group.deliveryTime.length == 0 || !date || [date timeIntervalSince1970] == 0) {
				date = [[NSDate alloc] init];
			}
			
			[_cell.datePicker setDate:date animated:NO];
			
			return cell;
		}
		
		UITextField *field = [(TextFieldCell *)cell textField];
		[field setSpellCheckingType:UITextSpellCheckingTypeNo];
		[field setAutocapitalizationType:UITextAutocapitalizationTypeWords];
		[field setAutocorrectionType:UITextAutocorrectionTypeNo];
		[field setReturnKeyType:UIReturnKeyDone];
		[field setDelegate:self];
		
		[field removeTarget:nil action:nil forControlEvents:UIControlEventAllEditingEvents];
		
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
			[field setClearButtonMode:UITextFieldViewModeWhileEditing];
			[field setEnabled:true];
			
			if (table.takeaway)
				[[(TextFieldCell *)cell label] setText:@"Takeaway Time:"];
			else {
				[[(TextFieldCell *)cell label] setText:@"Deliver At:"];
				[field setEnabled:false];
			}
			[field setText:group.deliveryTime];
			[field setPlaceholder:@"7:40 pm (time)"];
			[field setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
			[field addTarget:self action:@selector(dismissDeliveryTime:) forControlEvents:UIControlEventEditingDidEnd];
			[field addTarget:self action:@selector(beganDeliveryTime:) forControlEvents:UIControlEventEditingDidBegin];
		} else if (indexPath.row == 3 || (indexPath.row == 4 && table.delivery && showsDatePicker)) {
			[[(TextFieldCell *)cell label] setText:@"Start Cooking At:"];
			[field setText:group.cookingTime];
			[field setClearButtonMode:UITextFieldViewModeWhileEditing];
			[field setPlaceholder:@"7:10 pm (time)"];
			[field setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
			[field addTarget:self action:@selector(dismissCookingTime:) forControlEvents:UIControlEventEditingDidEnd];
			[field addTarget:self action:@selector(beganCookingTime:) forControlEvents:UIControlEventEditingDidBegin];
		}
	} else if (indexPath.section == 3 || indexPath.section == 4) {
		[cell.textLabel setText:@"Select Discounts"];
	}
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Order *o;
	//if (indexPath.section == 0) return;
	
	if (indexPath.section == 1) {
		if (indexPath.row == 1) {
			[self printButton:indexPath];
			return;
		}
		
		o = [[Order alloc] init];
		o.group = group;
		[o save];
		
		NSMutableArray *orders = [group.orders mutableCopy];
		[orders addObject:o];
		group.orders = orders;
		table.orders = (int)group.orders.count;
		
		[self reloadParentView];
		[group setOrders:orders];
	} else if (indexPath.section == 0) {
		o = [group.orders objectAtIndex:indexPath.row];
	} else if (indexPath.section == 2 || (indexPath.section == 3 && table.delivery)) {
		if (table.delivery && indexPath.section == 3 && indexPath.row == 2) {
			// Delivery.. show magic date picking thing.
			[self showHideDatePicker];
			
			return;
		}
		
		TextFieldCell *cell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:indexPath];
		[cell.textField becomeFirstResponder];
		
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		
		return;
	} else if (indexPath.section == 3 || indexPath.section == 4) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			UINavigationController *navvc = [[self.navigationController storyboard] instantiateViewControllerWithIdentifier:@"openDiscounts"];
			DiscountsViewController *discounts = (DiscountsViewController *)[[navvc viewControllers] objectAtIndex:0];
			discounts.group = self.group;
			
			popover = [[UIPopoverController alloc] initWithContentViewController:navvc];
			popover.popoverContentSize = CGSizeMake(320, 416);
			UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
			[popover presentPopoverFromRect:cell.bounds inView:cell.contentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
			popover.delegate = self;
			
			return;
		}
		
		[self performSegueWithIdentifier:@"openDiscounts" sender:nil];
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
	if (section == 2) {
		return @"Customer Details";
	}
	if ((section == 3 && !table.delivery) || (section == 4 && table.delivery)) {
		return @"Discounts";
	}
	
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 2 && group.postcodeDistance.length > 0) {
		return [@"Distance to target: " stringByAppendingString:group.postcodeDistance];
	}
	if ((section == 4 || (section == 3 && !table.delivery)) && group.discounts.count > 0) {
		return [NSString stringWithFormat:@"%d Discount%@ Applied", group.discounts.count, group.discounts.count > 1 ? @"s" : @""];
	}
	if ((section == 4 && !table.delivery) || (section == 5 && table.delivery)) {
		NSMutableString *printouts = [[NSMutableString alloc] init];
		for (NSDictionary *printout in group.printouts) {
			[printouts appendFormat:@"Final Bill Printed by %@ at %@\n", [printout objectForKey:@"employee"], [printout objectForKey:@"time"]];
		}
		
		return printouts;
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
	
	table.orders = (int)group.orders.count;
	
	[self reloadParentView];
	[tableView reloadData];
	[self setEditing:false];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 3 && table.delivery && showsDatePicker) {
		return 216;
	}
	
	return 44;
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
	
	TextFieldCell *cell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow: showsDatePicker ? 4 : 3 inSection:3]];
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
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:3];
	if (table.takeaway) {
		indexPath = [NSIndexPath indexPathForRow:2 inSection:2];
	}
	TextFieldCell *cell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	[cell.textField resignFirstResponder];
	group.deliveryTime = cell.textField.text;
	
	[group save];
}

- (void)deliveryDateChanged:(UIDatePicker *)datePicker {
	NSDate *date = [datePicker date];
	NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
	timeFormatter.dateFormat = @"hh:mm a";
	
	self.group.deliveryTime = [timeFormatter stringFromDate:date];
	TextFieldCell *cell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:3]];
	[cell.textField setText:self.group.deliveryTime];
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

#pragma mark Customer Name

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
	if (!table.delivery) {
		section = 2;
	}
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
	TextFieldCell *cell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	[cell.textField resignFirstResponder];
	group.customerName = cell.textField.text;
	table.customerName = cell.textField.text;
	
	[self reloadParentView];
	[group save];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	
	return YES;
}

#pragma mark - Date Picker stuff

- (void)showHideDatePicker {
	[self.tableView beginUpdates];
	
	NSArray *_indexPath = @[[NSIndexPath indexPathForRow:3 inSection:3]];
	
	if (showsDatePicker) {
		[self hideDatePicker];
		[self.group save];
		[self.tableView deleteRowsAtIndexPaths:_indexPath withRowAnimation:UITableViewRowAnimationFade];
	} else {
		[self showDatePicker];
		[self.tableView insertRowsAtIndexPaths:_indexPath withRowAnimation:UITableViewRowAnimationFade];
	}
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	
	[self.tableView endUpdates];
	
	[self.tableView scrollToRowAtIndexPath:[_indexPath objectAtIndex:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)showDatePicker {
	showsDatePicker = true;
}

- (void)hideDatePicker {
	showsDatePicker = false;
}

@end

@implementation OrdersViewController (PopoverDelegate)

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	if (popoverController == popover) {
		popover = nil;
		[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	}
}

@end
