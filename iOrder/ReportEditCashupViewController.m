//
//  ReportEditCashupViewController.m
//  OrderChef
//
//  Created by Matej Kramny on 22/05/2014.
//  Copyright (c) 2014 Matej Kramny. All rights reserved.
//

#import "ReportEditCashupViewController.h"
#import "Storage.h"
#import "Connection.h"
#import "AppDelegate.h"
#import "ReportDateRangeViewController.h"
#import "ReportSalesReportTableViewController.h"
#import "DatePickerTableViewCell.h"
#import "TextFieldCell.h"
#import "ButtonsTableViewCell.h"
#import "ReportPopularDishesTableViewController.h"
#import "ReportCashingUpViewController.h"

@interface ReportEditCashupViewController () {
	bool showsDatePicker;
	NSTimeInterval timeInterval;
}

@end

@implementation ReportEditCashupViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	timeInterval = [[[NSDate alloc] init] timeIntervalSince1970];
	
	[self.navigationItem setTitle:@"Reports"];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		if (showsDatePicker)
			return 2;
		return 1;
	}
	
	if (section == 1) {
		return 6;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	__unused static NSString *leftDetailCellID = @"leftDetail";
	__unused static NSString *rightDetailCellID = @"rightDetail";
	__unused static NSString *basicCellID = @"basic";
	__unused static NSString *datePickerSelector = @"datePickerSelector";
	__unused static NSString *datePickerCell = @"datePickerCell";
	__unused static NSString *textCellID = @"text";
	__unused static NSString *labelTextCellID = @"label_text";
	
	NSString *cellID;
	if (indexPath.section == 0) {
		cellID = basicCellID;
		
		if (indexPath.row == 1 && showsDatePicker) {
			cellID = datePickerSelector;
		}
	} else if (indexPath.section == 1) {
		cellID = basicCellID;
	}
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
	
	if (indexPath.section == 0) {
		NSString *targetSelector = @"datePickerStart:";
		
		if ([cellID isEqualToString:datePickerSelector]) {
			DatePickerTableViewCell *_cell = (DatePickerTableViewCell *)cell;
			if (!_cell) {
				cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:datePickerSelector];
				_cell = (DatePickerTableViewCell *)cell;
			}
			
			[_cell.datePicker setDatePickerMode:UIDatePickerModeDate];
			[_cell.datePicker removeTarget:nil action:nil forControlEvents:UIControlEventValueChanged];
			
			[_cell.datePicker addTarget:self action:NSSelectorFromString(targetSelector) forControlEvents:UIControlEventValueChanged];
			
			[_cell.datePicker setMinimumDate:nil];
			[_cell.datePicker setMaximumDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
			
			if (!timeInterval) {
				timeInterval = [[[NSDate alloc] init] timeIntervalSince1970];
			}
			
			NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
			[_cell.datePicker setDate:date animated:NO];
		} else {
			cell.textLabel.text = @"CashUp Date:";
		}
	}
	
	if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			cell.textLabel.text = @"Cash";
		} else if (indexPath.row == 1) {
			cell.textLabel.text = @"Card";
		} else if (indexPath.row == 2) {
			cell.textLabel.text = @"Voucher";
		} else if (indexPath.row == 3) {
			cell.textLabel.text = @"Petty Cash";
		}
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	/*if (indexPath.section == 0) {
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
		return;
	} else if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			// Show/hide the start date picker
			if (showsDatePicker[self showHideEnd];
			[self showHideStart];
		} else if ([[tableView cellForRowAtIndexPath:indexPath] isMemberOfClass:[TextFieldCell class]]) {
			// Show/hide the end date picker
			if (showsDatePicker) [self showHideStart];
			[self showHideEnd];
		}
	} else if (indexPath.section == 2) {
		// View date range.
		NSDate *start = [NSDate dateWithTimeIntervalSince1970:timeInterval];
		NSDate *end = [NSDate dateWithTimeIntervalSince1970:timeInterval
		
		NSCalendar *cal = [NSCalendar currentCalendar];
		NSDateComponents *comps = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:start];
		
		start = [cal dateFromComponents:comps];
		
		comps = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:end];
		end = [NSDate dateWithTimeIntervalSince1970:((int)[[cal dateFromComponents:comps] timeIntervalSince1970] + (60 * 60 * 24))];
		
		NSString *destination;
		
		if (indexPath.row == 0) {
			destination = @"viewOrdersForDate";
		} else if (indexPath.row == 1) {
			destination = @"reportSales";
		} else if (indexPath.row == 2) {
			destination = @"reportPopularDishes";
		} else if (indexPath.row == 3) {
			destination = @"reportCashingUp";
		} else {
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			return;
		}
		
		[self performSegueWithIdentifier:destination sender:@[start, end]];
	}*/
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1 && (
								   ((indexPath.row == 2 && !showsDatePicker) || (indexPath.row == 3 && showsDatePicker)) ||
								   (indexPath.row == 1 && showsDatePicker))) {
		return 216;
	}
	
	return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Step 1. Set Report Date Range";
	}
	if (section == 2) {
		return @"Step 2. Choose Report Type";
	}
	
	return nil;
}

#pragma mark - DatePicker Targets

- (void)datePickerStart:(UIDatePicker *)datePicker {
	timeInterval = [[datePicker date] timeIntervalSince1970];
	
	TextFieldCell *cell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"dd/MM/yy"];
	cell.textField.text = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
}

- (void)showHideStart {
	[self.tableView beginUpdates];
	
	NSArray *_indexPath = @[[NSIndexPath indexPathForRow:1 inSection:1]];
	
	if (showsDatePicker) {
		showsDatePicker = false;
		[self.tableView deleteRowsAtIndexPaths:_indexPath withRowAnimation:UITableViewRowAnimationFade];
	} else {
		showsDatePicker = true;
		[self.tableView insertRowsAtIndexPaths:_indexPath withRowAnimation:UITableViewRowAnimationFade];
	}
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	
	[self.tableView endUpdates];
	
	[self.tableView scrollToRowAtIndexPath:[_indexPath objectAtIndex:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}
@end
