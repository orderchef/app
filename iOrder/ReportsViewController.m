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
#import "ReportSalesReportTableViewController.h"
#import "DatePickerTableViewCell.h"
#import "TextFieldCell.h"
#import "ButtonsTableViewCell.h"
#import "ReportPopularDishesTableViewController.h"
#import "ReportCashingUpViewController.h"

@interface ReportsViewController () {
	bool showsStartDatePicker;
	bool showsEndDatePicker;
	
	NSTimeInterval startTimeInterval;
	NSTimeInterval endTimeInterval;
	
	int timeEnabled; // 1<<1 = today, 1<<2 = week, 1<<3 = month
}

@end

@implementation ReportsViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	startTimeInterval = [[[NSDate alloc] init] timeIntervalSince1970];
	endTimeInterval = startTimeInterval;
	
	timeEnabled = 1 << 1;
	
	[self.navigationItem setTitle:@"Reports"];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[self setEnabledDisabled];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"viewOrdersForDate"]) {
		NSArray *dates = (NSArray *)sender;
		ReportDateRangeViewController *vc = (ReportDateRangeViewController *)[segue destinationViewController];
		vc.dateRange = dates;
	} else if ([segue.identifier isEqualToString:@"reportSales"]) {
		NSArray *dates = (NSArray *)sender;
		ReportSalesReportTableViewController *vc = (ReportSalesReportTableViewController *)[segue destinationViewController];
		vc.dateRange = dates;
	} else if ([segue.identifier isEqualToString:@"reportPopularDishes"]) {
		NSArray *dates = (NSArray *)sender;
		ReportPopularDishesTableViewController *vc = (ReportPopularDishesTableViewController *)[segue destinationViewController];
		vc.dateRange = dates;
	} else if ([segue.identifier isEqualToString:@"reportCashingUp"]) {
		NSArray *dates = (NSArray *)sender;
		ReportCashingUpViewController *vc = (ReportCashingUpViewController *)[segue destinationViewController];
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
		return 4;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	__unused static NSString *leftDetailCellID = @"leftDetail";
	__unused static NSString *rightDetailCellID = @"rightDetail";
	__unused static NSString *basicCellID = @"basic";
	__unused static NSString *datePickerSelector = @"datePickerSelector";
	__unused static NSString *datePickerCell = @"datePickerCell";
	__unused static NSString *buttonCell = @"buttonCell";
	
	NSString *cellID;
	if (indexPath.section == 0) {
		cellID = buttonCell;
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
		if (!cell) {
			cell = [[ButtonsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:buttonCell];
		}
		
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		
		ButtonsTableViewCell *_cell = (ButtonsTableViewCell *)cell;
		[_cell.button1 removeTarget:self action:@selector(setDateToday:) forControlEvents:UIControlEventTouchUpInside];
		[_cell.button1 addTarget:self action:@selector(setDateToday:) forControlEvents:UIControlEventTouchUpInside];
		[_cell.button2 removeTarget:self action:@selector(setDateWeek:) forControlEvents:UIControlEventTouchUpInside];
		[_cell.button2 addTarget:self action:@selector(setDateWeek:) forControlEvents:UIControlEventTouchUpInside];
		[_cell.button3 removeTarget:self action:@selector(setDateMonth:) forControlEvents:UIControlEventTouchUpInside];
		[_cell.button3 addTarget:self action:@selector(setDateMonth:) forControlEvents:UIControlEventTouchUpInside];
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
		} else if (indexPath.row == 2) {
			cell.textLabel.text = @"Popular Dishes";
		} else if (indexPath.row == 3) {
			cell.textLabel.text = @"Cashing Up Report";
		}
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
		return;
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
		return @"Step 1. Set Report Date Range";
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
	
	timeEnabled = 0;
	[self setEnabledDisabled];
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
	
	timeEnabled = 0;
	[self setEnabledDisabled];
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
	
	[self.tableView scrollToRowAtIndexPath:[_indexPath objectAtIndex:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
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
		[self.tableView scrollToRowAtIndexPath:[_indexPath objectAtIndex:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)setDateToday:(UIButton *)button {
	timeEnabled = 1 << 1;
	[self setEnabledDisabled];
	
	NSDate *now = [NSDate date];
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents *comps = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:now];
	
	NSDate *today_start = [cal dateFromComponents:comps];
	startTimeInterval = [today_start timeIntervalSince1970];
	endTimeInterval = startTimeInterval;
	
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setDateWeek:(id)sender {
	[self setDateToday:sender];
	
	timeEnabled = 1 << 2;
	[self setEnabledDisabled];
	
	NSDateComponents *components = [[NSCalendar currentCalendar] components: NSYearCalendarUnit | NSWeekOfYearCalendarUnit fromDate:[NSDate date]];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	
	[comps setWeekOfYear:[components weekOfYear]-1];
	[comps setWeekday:2];
	[comps setYear:[components year]];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	[calendar setFirstWeekday:2]; //This needs to be checked, which day is monday?
	NSDate *date = [calendar dateFromComponents:comps];
	
	startTimeInterval = [date timeIntervalSince1970];
	
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setDateMonth:(id)sender {
	timeEnabled = 1 << 3;
	[self setEnabledDisabled];
	
	NSDate *now = [NSDate date];
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents *comps = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:now];
	
	endTimeInterval = ([[cal dateFromComponents:comps] timeIntervalSince1970]);
	
	[comps setDay:1];
	startTimeInterval = [[cal dateFromComponents:comps] timeIntervalSince1970];
	
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setEnabledDisabled {
	ButtonsTableViewCell *cell = (ButtonsTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	[cell.button1 setEnabled: !(timeEnabled & (1 << 1))];
	[cell.button2 setEnabled: !(timeEnabled & (1 << 2))];
	[cell.button3 setEnabled: !(timeEnabled & (1 << 3))];
}

@end
