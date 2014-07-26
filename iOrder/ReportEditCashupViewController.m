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
	__weak UITextField *editedTextField;
}

@end

@implementation ReportEditCashupViewController

@synthesize cashReport;
@synthesize justEat;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.navigationItem setTitle:@"Cash Report"];
	if (self.justEat) {
		[self.navigationItem setTitle:@"JustEat Receipt"];
	}
	
	if (!cashReport) {
		cashReport = [[NSMutableDictionary alloc] init];
		if (self.justEat) {
			[cashReport setObject:[NSNumber numberWithBool:true] forKey:@"isJustEat"];
		}
	} else {
		if ([cashReport objectForKey:@"isJustEat"]) {
			self.justEat = [[cashReport objectForKey:@"isJustEat"] boolValue];
		}
	}
	
	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveReport:)]];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)saveReport:(id)sender {
	if (editedTextField) {
		[editedTextField resignFirstResponder];
	}
	
	[[Connection getConnection].socket sendEvent:@"save.cashup" withData:cashReport];
	
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return 2;
	}
	
	if (section == 1) {
		if (self.justEat) return 3;
		return 6;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	__unused static NSString *leftDetailCellID = @"leftDetail";
	__unused static NSString *rightDetailCellID = @"rightDetail";
	__unused static NSString *basicCellID = @"basic";
	__unused static NSString *datePickerSelector = @"datePickerSelector";
	__unused static NSString *datePickerCell = @"datePicker";
	__unused static NSString *textCellID = @"text";
	__unused static NSString *labelTextCellID = @"label_text";
	
	NSString *cellID;
	if (indexPath.section == 0) {
		cellID = labelTextCellID;
		
		if (indexPath.row == 1) {
			cellID = datePickerCell;
		}
	} else if (indexPath.section == 1) {
		cellID = labelTextCellID;
	}
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
	
	if (indexPath.section == 0) {
		NSString *targetSelector = @"datePickerStart:";
		
		if ([cellID isEqualToString:datePickerCell]) {
			DatePickerTableViewCell *_cell = (DatePickerTableViewCell *)cell;
			if (!_cell) {
				cell = [[DatePickerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:datePickerSelector];
				_cell = (DatePickerTableViewCell *)cell;
			}
			
			[_cell.datePicker setDatePickerMode:UIDatePickerModeDate];
			if (self.justEat)
				[_cell.datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
			
			[_cell.datePicker removeTarget:nil action:nil forControlEvents:UIControlEventValueChanged];
			
			[_cell.datePicker addTarget:self action:NSSelectorFromString(targetSelector) forControlEvents:UIControlEventValueChanged];
			
			NSTimeInterval timeInterval = [[cashReport objectForKey:@"created"] longValue];
			
			NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
			[_cell.datePicker setDate:date animated:NO];
		} else {
			TextFieldCell *_cell = (TextFieldCell *)cell;
			if (!_cell) {
				cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:labelTextCellID];
			}
			
			NSTimeInterval timeInterval;
			if (![cashReport objectForKey:@"created"]) {
				[cashReport setObject:[NSNumber numberWithLong:[[[NSDate alloc] init] timeIntervalSince1970]] forKey:@"created"];
			}
			timeInterval = [[cashReport objectForKey:@"created"] longValue];
			
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setDateFormat:@"dd/MM/yy"];
			if (self.justEat)
				[dateFormatter setDateFormat:@"dd/MM/yy hh:mm"];
			_cell.textField.text = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
			
			[_cell label].text = @"Cash Report Date";
			if (self.justEat)
				_cell.label.text = @"Receipt Date";
			[[_cell textField] setTextAlignment:NSTextAlignmentRight];
			[[_cell textField] setEnabled:false];
		}
	}
	
	if (indexPath.section == 1) {
		TextFieldCell *_cell = (TextFieldCell *)cell;
		if (!_cell) {
			cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:labelTextCellID];
		}
		
		[[_cell textField] setTextAlignment:NSTextAlignmentRight];
		[[_cell textField] setPlaceholder:@"0.00"];
		[_cell.textField setDelegate:self];
		[_cell.textField setReturnKeyType:UIReturnKeyNext];
		[_cell.textField setClearButtonMode:UITextFieldViewModeNever];
		
		float number = 0.f;
		NSString *key;
		
		if (indexPath.row == 0 && self.justEat) {
			_cell.label.text = @"JustEat Paid";
			[_cell.textField setTag:1];
			key = @"justEat";
		} else if (indexPath.row == 0 && !self.justEat) {
			_cell.label.text = @"Cash";
			[_cell.textField setTag:1];
			key = @"cash";
		} else if (indexPath.row == 1 && self.justEat) {
			_cell.label.text = @"JustEat Total";
			[_cell.textField setTag:2];
			key = @"justEatUnpaid";
		} else if (indexPath.row == 1 && !self.justEat) {
			_cell.label.text = @"Card";
			[_cell.textField setTag:2];
			key = @"card";
		} else if (indexPath.row == 2 && self.justEat) {
			_cell.label.text = @"Delivery Charge";
			[_cell.textField setTag:3];
			key = @"justEatDelivery";
			[_cell.textField setReturnKeyType:UIReturnKeyDone];
		} else if (indexPath.row == 2 && !self.justEat) {
			_cell.label.text = @"Voucher";
			[_cell.textField setTag:3];
			key = @"voucher";
		} else if (indexPath.row == 3) {
			_cell.label.text = @"Petty Cash";
			[_cell.textField setTag:4];
			key = @"pettyCash";
		} else if (indexPath.row == 4) {
			_cell.label.text = @"Labour";
			[_cell.textField setTag:5];
			key = @"labour";
		} else if (indexPath.row == 5) {
			_cell.label.text = @"Tips";
			[_cell.textField setTag:6];
			[_cell.textField setReturnKeyType:UIReturnKeyDone];
			key = @"tips";
		}
		
		if ([cashReport objectForKey:key]) {
			number = [[cashReport objectForKey:key] floatValue];
			[_cell.textField setText:[NSString stringWithFormat:@"%.2f", number]];
		}
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1) {
		TextFieldCell *cell = (TextFieldCell *)[tableView cellForRowAtIndexPath:indexPath];
		[cell.textField becomeFirstResponder];
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 1) {
		return 216;
	}
	
	return 44;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	int tag = [textField tag];
	
	if (tag >= 6 || (self.justEat && tag == 3)) {
		[textField resignFirstResponder];
		return YES;
	}
	
	TextFieldCell *cell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tag inSection:1]];
	[cell.textField becomeFirstResponder];
	
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	int tag = [textField tag];
	
	NSNumber *number = [NSNumber numberWithFloat:[[textField text] floatValue]];
	if (!number) number = [NSNumber numberWithFloat:0.f];
	NSString *key = nil;
	
	switch (tag) {
		case 1:
			key = @"cash";
			if (self.justEat)
				key = @"justEat";
			break;
		case 2:
			key = @"card";
			if (self.justEat)
				key = @"justEatUnpaid";
			break;
		case 3:
			key = @"voucher";
			if (self.justEat)
				key = @"justEatDelivery";
			break;
		case 4:
			key = @"pettyCash";
			break;
		case 5:
			key = @"labour";
			break;
		case 6:
			key = @"tips";
			break;
		default:
			return;
	}
	
	[cashReport setObject:number forKey:key];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	editedTextField = textField;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (self.justEat && section == 1) {
		return @"JustEat Total goes to the Sales Report, Paid goes to the Cash Report.";
	}
	
	return nil;
}

#pragma mark - DatePicker Targets

- (void)datePickerStart:(UIDatePicker *)datePicker {
	NSTimeInterval timeInterval = [[datePicker date] timeIntervalSince1970];
	[cashReport setObject:[NSNumber numberWithLong:timeInterval] forKey:@"created"];
	
	TextFieldCell *cell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"dd/MM/yy"];
	cell.textField.text = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
}

@end
