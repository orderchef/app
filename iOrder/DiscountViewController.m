//
//  DiscountsViewController.m
//  OrderChef
//
//  Created by Matej Kramny on 07/02/2014.
//  Copyright (c) 2014 Matej Kramny. All rights reserved.
//

#import "DiscountViewController.h"
#import "TextFieldCell.h"
#import "TextSwitchCell.h"
#import "Discount.h"
#import "DiscountCategoriesViewController.h"
#import "DiscountTablesViewController.h"

@interface DiscountViewController ()

@end

@implementation DiscountViewController

@synthesize discount;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.navigationItem setTitle:@"New Discount"];
	if (discount) {
		[self.navigationItem setTitle:[discount name]];
	}
	
	
	if (discount._id.length > 0) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"\uf014 " style:UIBarButtonItemStylePlain target:self action:@selector(deleteDiscount:)];
		[self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{
																		 NSFontAttributeName: [UIFont fontWithName:@"FontAwesome" size:24]
																		 } forState:UIControlStateNormal];
	}
}

- (void)deleteDiscount:(id)sender {
	
}

- (void)discountPercentChanged:(id)sender {
	[discount setDiscountPercent:[(UISwitch *)sender isOn]];
}

- (void)allCategoriesChanged:(id)sender {
	[discount setAllCategories:[(UISwitch *)sender isOn]];
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
	//[discount setCategories:[[NSArray alloc] init]];
}

- (void)allTablesChanged:(id)sender {
	[discount setAllTables:[(UISwitch *)sender isOn]];
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
	//[discount setTables:[[NSArray alloc] init]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"openCategories"]) {
		DiscountCategoriesViewController *vc = segue.destinationViewController;
		vc.discount = discount;
	} else if ([[segue identifier] isEqualToString:@"openTables"]) {
		DiscountTablesViewController *vc = segue.destinationViewController;
		vc.discount = discount;
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return 1; // Name
	}
	if (section == 1) {
		return 2; // Value & Percentage Switch
	}
	if (section == 2) {
		// All Tables & Tables
		if (discount.allTables == false)
			return 2;
		
		return 1;
	}
	if (section == 3) {
		// All Categories & Categories
		if (discount.allCategories == false)
			return 2;
		
		return 1;
	}
	
	return 0;
}

static NSString *textCellID = @"text";
static NSString *valueCellID = @"value";
static NSString *switchCellID = @"switchCell";
static NSString *selectCellID = @"select";

- (TextFieldCell *)allocTextCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
	TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:textCellID forIndexPath:indexPath];
	if (!cell)
		cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:textCellID];
	
	return cell;
}

- (TextSwitchCell *)allocSwitchCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
	TextSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:switchCellID forIndexPath:indexPath];
	if (!cell)
		cell = [[TextSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:switchCellID];
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		TextFieldCell *cell = [self allocTextCell:tableView indexPath:indexPath];
		
		cell.textField.placeholder = @"Discount Name";
		if (discount && discount._id.length > 0) {
			cell.textField.text = [discount name];
		}
		cell.textField.delegate = self;
		
		return cell;
	}
	if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:valueCellID forIndexPath:indexPath];
			if (!cell)
				cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:valueCellID];
			
			cell.label.text = @"Discount Value";
			cell.textField.placeholder = @"0.00";
			if (discount && discount._id.length > 0) {
				cell.textField.text = [NSString stringWithFormat:@"%.f", discount.value];
			}
			
			return cell;
		} else if (indexPath.row == 1) {
			TextSwitchCell *cell = [self allocSwitchCell:tableView indexPath:indexPath];
			
			cell.label.text = @"Percentage";
			cell.checkbox.on = false;
			if (discount && discount._id.length > 0) {
				cell.checkbox.on = discount.discountPercent;
			}
			[cell.checkbox removeTarget:self action:@selector(discountPercentChanged:) forControlEvents:UIControlEventValueChanged];
			[cell.checkbox addTarget:self action:@selector(discountPercentChanged:) forControlEvents:UIControlEventValueChanged];
			
			return cell;
		}
	}
	if (indexPath.section == 2) {
		if (indexPath.row == 0) {
			TextSwitchCell *cell = [self allocSwitchCell:tableView indexPath:indexPath];
			
			cell.label.text = @"All Tables";
			cell.checkbox.on = false;
			if (discount && discount._id.length > 0) {
				cell.checkbox.on = discount.allTables;
			}
			[cell.checkbox removeTarget:self action:@selector(allTablesChanged:) forControlEvents:UIControlEventValueChanged];
			[cell.checkbox addTarget:self action:@selector(allTablesChanged:) forControlEvents:UIControlEventValueChanged];
			
			return cell;
		} else if (indexPath.row == 1) {
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:selectCellID forIndexPath:indexPath];
			cell.textLabel.text = @"Select Tables";
			
			return cell;
		}
	}
	if (indexPath.section == 3) {
		if (indexPath.row == 0) {
			TextSwitchCell *cell = [self allocSwitchCell:tableView indexPath:indexPath];
			
			cell.label.text = @"All Categories";
			cell.checkbox.on = false;
			if (discount && discount._id.length > 0) {
				cell.checkbox.on = discount.allCategories;
			}
			[cell.checkbox removeTarget:self action:@selector(allCategoriesChanged:) forControlEvents:UIControlEventValueChanged];
			[cell.checkbox addTarget:self action:@selector(allCategoriesChanged:) forControlEvents:UIControlEventValueChanged];
			
			return cell;
		} else if (indexPath.row == 1) {
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:selectCellID forIndexPath:indexPath];
			cell.textLabel.text = @"Select Categories";
			
			return cell;
		}
	}
	
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[[(TextFieldCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] textField] resignFirstResponder];
	[[(TextFieldCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] textField] resignFirstResponder];
	
	if (indexPath.section == 0) {
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		[[(TextFieldCell *)cell textField] becomeFirstResponder];
	} else if (indexPath.section == 1 && indexPath.row == 0) {
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		[[(TextFieldCell *)cell textField] becomeFirstResponder];
	} else if (indexPath.section == 2 && indexPath.row == 1) {
		[self performSegueWithIdentifier:@"openTables" sender:nil];
	} else if (indexPath.section == 3 && indexPath.row == 1) {
		[self performSegueWithIdentifier:@"openCategories" sender:nil];
	}
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

@end
