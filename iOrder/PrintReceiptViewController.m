//
//  PrintReceiptViewController.m
//  OrderChef
//
//  Created by Matej Kramny on 10/05/2014.
//  Copyright (c) 2014 Matej Kramny. All rights reserved.
//

#import "PrintReceiptViewController.h"
#import "Connection.h"
#import "AppDelegate.h"
#import "Storage.h"
#import "Employee.h"
#import "OrderGroup.h"
#import "OrdersViewController.h"

@interface PrintReceiptViewController () {
	UITapGestureRecognizer *tapToCancelRecognizer;
}

@end

@implementation PrintReceiptViewController

@synthesize group;
@synthesize popover;
@synthesize textView;
@synthesize parentView;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	
	NSString *employeeName = [Storage getStorage].employee.name;
	if (!employeeName) {
		employeeName = @"";
	}
	
	tapToCancelRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelLoading:)];
	[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:@"Loading Final Bill" detail:@"Touch to Cancel" hideAfter:0 showAnimated:NO hideAnimated:NO hide:NO tapRecognizer:tapToCancelRecognizer toView:self.navigationController.view];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadedReceipt:) name:kReceiptNotificationName object:nil];
	
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
		[self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelLoading:)]];
	}
	
	[[Connection getConnection].socket sendEvent:@"print.group" withData:@{
																		   @"group": group._id,
																		   @"employee": employeeName,
																		   @"do_not_print": [NSNumber numberWithBool:true]
																		   }];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kReceiptNotificationName object:nil];
}

- (void)loadedReceipt:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	
	[textView setText:[userInfo objectForKey:@"data"]];
	[textView setFont:[UIFont fontWithName:@"Courier New" size:14.f]];
	[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:@"Receipt Loaded" detail:@"Please Review and Print" hideAfter:0.2 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:self.navigationController.view];
}

- (void)cancelLoading:(id)sender {
	[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:@"Cancelled.." detail:nil hideAfter:0.2 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:self.navigationController.view];
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)printAndClear:(UIBarButtonItem *)sender {
	// Prints 2x
	NSString *employeeName = [Storage getStorage].employee.name;
	if (!employeeName) {
		employeeName = @"";
	}
	
	[[Connection getConnection].socket sendEvent:@"print.group" withData:@{
																		   @"group": group._id,
																		   @"employee": employeeName,
																		   @"bar_copy": [NSNumber numberWithBool:true]
																		   }];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[popover dismissPopoverAnimated:YES];
	} else {
		[self.navigationController dismissViewControllerAnimated:YES completion:nil];
	}
	
	[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:@"Receipt Printed" detail:@"2 Copies Printed, Table Cleared" hideAfter:0.8 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:parentView.view];
	
	if (!group.cleared) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[group clear];
			if (parentView) {
				[parentView refreshOrders:nil];
			}
		});
	}
}

- (IBAction)print:(UIBarButtonItem *)sender {
	[group printBill];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[popover dismissPopoverAnimated:YES];
	} else {
		[self.navigationController dismissViewControllerAnimated:YES completion:nil];
	}
	
	[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:@"Receipt Printed" detail:nil hideAfter:0.8 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:parentView.view];
}

@end
