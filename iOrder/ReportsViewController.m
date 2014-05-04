//
//  ReportsViewController.m
//  iOrder
//
//  Created by Matej Kramny on 15/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "ReportsViewController.h"
#import "Storage.h"
#import "Connection.h"
#import "AppDelegate.h"
#import "ReportDateRangeViewController.h"
#import "DatePickerTableViewCell.h"
#import "TextFieldCell.h"

@interface ReportsViewController () {
	bool showsStartDatePicker;
	bool showsEndDatePicker;
	
	NSTimeInterval startTimeInterval;
	NSTimeInterval endTimeInterval;
}

@end

@implementation ReportsViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	startTimeInterval = [[[NSDate alloc] init] timeIntervalSince1970];
	endTimeInterval = startTimeInterval;
	
	[self.navigationItem setTitle:@"Reports"];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"viewOrdersForDate"]) {
		NSArray *dates = (NSArray *)sender;
		ReportDateRangeViewController *vc = (ReportDateRangeViewController *)[segue destinationViewController];
		vc.dateRange = dates;
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return 1;
	}
	
	if (section == 1) {
		int rows = 2;
		if (showsStartDatePicker) rows++;
		if (showsEndDatePicker) rows++;
		
		return rows;
	}
	
	if (section == 2) {
		return 2;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	__unused static NSString *leftDetailCellID = @"leftDetail";
	__unused static NSString *rightDetailCellID = @"rightDetail";
	__unused static NSString *basicCellID = @"basic";
	__unused static NSString *datePickerSelector = @"datePickerSelector";
	__unused static NSString *datePickerCell = @"datePickerCell";
	
	NSString *cellID;
	if (indexPath.section == 0) {
		cellID = basicCellID;
	} else if (indexPath.section == 1) {
		cellID = datePickerCell;
		
		if (indexPath.row == 1 && showsStartDatePicker) {
			cellID = datePickerSelector;
		}
		if (((indexPath.row == 2 && !showsStartDatePicker) || (indexPath.row == 3 && showsStartDatePicker)) && showsEndDatePicker) {
			cellID = datePickerSelector;
		}
	} else if (indexPath.section == 2) {
		cellID = basicCellID;
	} else if (indexPath.section == 3) {
		cellID = basicCellID;
	}
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
	
	if (indexPath.section == 0) {
		cell.textLabel.text = @"Today";
	}
	
	if (indexPath.section == 1) {
		NSTimeInterval timeInterval;
		NSString *targetSelector;
		if (indexPath.row == 0 || (indexPath.row == 1 && showsStartDatePicker)) {
			timeInterval = startTimeInterval;
			targetSelector = @"datePickerStart:";
		} else if (indexPath.row >= 1) {
			timeInterval = endTimeInterval;
			targetSelector = @"datePickerEnd:";
		}
		
		if ([cellID isEqualToString:datePickerSelector]) {
			DatePickerTableViewCell *_cell = (DatePickerTableViewCell *)cell;
			if (!_cell) {
				cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:datePickerSelector];
				_cell = (DatePickerTableViewCell *)cell;
			}
			
			[_cell.datePicker setDatePickerMode:UIDatePickerModeDate];
			[_cell.datePicker removeTarget:nil action:nil forControlEvents:UIControlEventValueChanged];
			
			[_cell.datePicker addTarget:self action:NSSelectorFromString(targetSelector) forControlEvents:UIControlEventValueChanged];
			
			if ([targetSelector isEqualToString:@"datePickerStart:"]) {
				// Start date
				[_cell.datePicker setMinimumDate:nil];
				[_cell.datePicker setMaximumDate:[NSDate dateWithTimeIntervalSince1970:endTimeInterval]];
			} else {
				// End date
				[_cell.datePicker setMinimumDate:[NSDate dateWithTimeIntervalSince1970:startTimeInterval]];
				[_cell.datePicker setMaximumDate:nil];
			}
			
			if (!timeInterval) {
				timeInterval = [[[NSDate alloc] init] timeIntervalSince1970];
			}
			
			NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
			[_cell.datePicker setDate:date animated:NO];
		} else {
			TextFieldCell *_cell = (TextFieldCell *)cell;
			if (!_cell) {
				cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:datePickerCell];
			}
			
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setDateFormat:@"dd/MM/yy"];
			_cell.textField.text = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
			[_cell.textField setEnabled:false];
			[_cell.textField setClearButtonMode:UITextFieldViewModeNever];
			[_cell.textField setTextAlignment:NSTextAlignmentRight];
			
			if (indexPath.row == 0) {
				_cell.label.text = @"Start Date:";
			} else {
				_cell.label.text = @"End Date:";
			}
		}
	}
	
	if (indexPath.section == 2) {
		if (indexPath.row == 0) {
			cell.textLabel.text = @"Past Orders";
		} else if (indexPath.row == 1) {
			cell.textLabel.text = @"Sales Report";
		}
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		NSDate *now = [NSDate date];
		NSCalendar *cal = [NSCalendar currentCalendar];
		NSDateComponents *comps = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:now];
		
		NSDate *today_start = [cal dateFromComponents:comps];
		NSDate *today_end = [NSDate dateWithTimeIntervalSince1970:((int)[today_start timeIntervalSince1970] + (60 * 60 * 24))];
		
		[self performSegueWithIdentifier:@"viewOrdersForDate" sender:@[today_start, today_end]];
	} else if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			// Show/hide the start date picker
			if (showsEndDatePicker) [self showHideEnd];
			[self showHideStart];
		} else if ([[tableView cellForRowAtIndexPath:indexPath] isMemberOfClass:[TextFieldCell class]]) {
			// Show/hide the end date picker
			if (showsStartDatePicker) [self showHideStart];
			[self showHideEnd];
		}
	} else if (indexPath.section == 2) {
		// View date range.
		NSDate *start = [NSDate dateWithTimeIntervalSince1970:startTimeInterval];
		NSDate *end = [NSDate dateWithTimeIntervalSince1970:endTimeInterval];
		
		NSCalendar *cal = [NSCalendar currentCalendar];
		NSDateComponents *comps = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:start];
		
		start = [cal dateFromComponents:comps];
		
		comps = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:end];
		end = [NSDate dateWithTimeIntervalSince1970:((int)[[cal dateFromComponents:comps] timeIntervalSince1970] + (60 * 60 * 24))];
		
		[self performSegueWithIdentifier:@"viewOrdersForDate" sender:@[start, end]];
	} else if (indexPath.section == 3) {
		NSString *destination;
		
		if (indexPath.row == 0) {
			destination = @"reportOrders";
		} else if (indexPath.row == 1) {
			destination = @"reportSales";
		} else {
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			return;
		}
		
		[self performSegueWithIdentifier:destination sender:nil];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1 && (
								   ((indexPath.row == 2 && !showsStartDatePicker) || (indexPath.row == 3 && showsStartDatePicker)) ||
								   (indexPath.row == 1 && showsStartDatePicker))) {
		return 216;
	}
	
	return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Step 1. Select Report Date";
	}
	if (section == 2) {
		return @"Step 2. Choose Report Type";
	}
	
	return nil;
}

#pragma mark - DatePicker Targets

- (void)datePickerStart:(UIDatePicker *)datePicker {
	startTimeInterval = [[datePicker date] timeIntervalSince1970];
	[datePicker setMaximumDate:[NSDate dateWithTimeIntervalSince1970:endTimeInterval]];
	
	TextFieldCell *cell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"dd/MM/yy"];
	cell.textField.text = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:startTimeInterval]];
}

- (void)datePickerEnd:(UIDatePicker *)datePicker {
	endTimeInterval = [[datePicker date] timeIntervalSince1970];
	
	[datePicker setMinimumDate:[NSDate dateWithTimeIntervalSince1970:startTimeInterval]];
	
	int row = 1;
	if (showsStartDatePicker) {
		row = 2;
	}
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
	TextFieldCell *cell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"dd/MM/yy"];
	cell.textField.text = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:endTimeInterval]];
}

- (void)showHideStart {
	[self.tableView beginUpdates];
	
	NSArray *_indexPath = @[[NSIndexPath indexPathForRow:1 inSection:1]];
	
	if (showsStartDatePicker) {
		showsStartDatePicker = false;
		[self.tableView deleteRowsAtIndexPaths:_indexPath withRowAnimation:UITableViewRowAnimationFade];
	} else {
		showsStartDatePicker = true;
		[self.tableView insertRowsAtIndexPaths:_indexPath withRowAnimation:UITableViewRowAnimationFade];
	}
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	
	[self.tableView endUpdates];
	
	[self.tableView scrollToRowAtIndexPath:[_indexPath objectAtIndex:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)showHideEnd {
	[self.tableView beginUpdates];
	
	int row = 2;
	if (showsStartDatePicker) {
		row = 3;
	}
	
	NSArray *_indexPath = @[[NSIndexPath indexPathForRow:row inSection:1]];
	
	if (showsEndDatePicker) {
		showsEndDatePicker = false;
		[self.tableView deleteRowsAtIndexPaths:_indexPath withRowAnimation:UITableViewRowAnimationFade];
	} else {
		showsEndDatePicker = true;
		[self.tableView insertRowsAtIndexPaths:_indexPath withRowAnimation:UITableViewRowAnimationFade];
	}
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	
	[self.tableView endUpdates];
	
	if (showsEndDatePicker)
		[self.tableView scrollToRowAtIndexPath:[_indexPath objectAtIndex:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

@end
