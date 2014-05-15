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
#import "AppDelegate.h"

@interface DiscountViewController () {
	bool save;
}

@end

@implementation DiscountViewController

@synthesize discount;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	save = true;
	
	[self.navigationItem setTitle:@"New Discount"];
	if (discount._id.length > 0) {
		[self.navigationItem setTitle:[discount name]];
	}
	
	
	if (discount._id.length > 0) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"\uf014 " style:UIBarButtonItemStylePlain target:self action:@selector(deleteDiscount:)];
		[self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{
																		 NSFontAttributeName: [UIFont fontWithName:@"FontAwesome" size:24]
																		 } forState:UIControlStateNormal];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	save = true;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	if (save && discount.name.length > 0) {
		discount.value = [[(TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] textField].text floatValue];
		discount.discountPercent = [[(TextSwitchCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]] checkbox] isOn];
		discount.allCategories = [[(TextSwitchCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]] checkbox] isOn];
		
		[discount save];
	}
}

- (void)deleteDiscount:(id)sender {
	save = false;
	
	[discount remove];
	[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:[discount.name stringByAppendingString:@" Deleted"] detail:Nil hideAfter:0.5 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:self.parentViewController.view];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)discountPercentChanged:(id)sender {
	[discount setDiscountPercent:[(UISwitch *)sender isOn]];
}

- (void)allCategoriesChanged:(id)sender {
	[discount setAllCategories:[(UISwitch *)sender isOn]];
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
	//[discount setCategories:[[NSArray alloc] init]];
}

- (void)orderSwitchFlipped:(UISwitch *)flip {
	[discount setOrder:[flip isOn]];
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	save = false;
	
	if ([[segue identifier] isEqualToString:@"openCategories"]) {
		DiscountCategoriesViewController *vc = segue.destinationViewController;
		vc.discount = discount;
	}
}

- (void)updateName:(UITextField *)sender {
	discount.name = sender.text;
	[self.navigationItem setTitle:discount.name];
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
		return 1;
	}
	if (section == 3) {
		if (discount.order) return 0;
		
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
		cell.textField.text = [discount name];
		cell.textField.delegate = self;
		[cell.textField addTarget:self action:@selector(updateName:) forControlEvents:UIControlEventEditingChanged];
		
		return cell;
	}
	if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:valueCellID forIndexPath:indexPath];
			if (!cell)
				cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:valueCellID];
			
			cell.label.text = @"Discount Value";
			cell.textField.placeholder = @"0.00";
			cell.textField.text = [NSString stringWithFormat:@"%.2f", discount.value];
			
			return cell;
		} else if (indexPath.row == 1) {
			TextSwitchCell *cell = [self allocSwitchCell:tableView indexPath:indexPath];
			
			cell.label.text = @"Percentage";
			cell.checkbox.on = discount.discountPercent;
			
			[cell.checkbox removeTarget:self action:@selector(discountPercentChanged:) forControlEvents:UIControlEventValueChanged];
			[cell.checkbox addTarget:self action:@selector(discountPercentChanged:) forControlEvents:UIControlEventValueChanged];
			
			return cell;
		}
	}
	if (indexPath.section == 2) {
		TextSwitchCell *cell = [self allocSwitchCell:tableView indexPath:indexPath];
		
		cell.label.text = @"Order Discount";
		cell.checkbox.on = false;
		cell.checkbox.on = discount.order;
		
		[cell.checkbox removeTarget:self action:@selector(orderSwitchFlipped:) forControlEvents:UIControlEventValueChanged];
		[cell.checkbox addTarget:self action:@selector(orderSwitchFlipped:) forControlEvents:UIControlEventValueChanged];
		
		return cell;
	}
	if (indexPath.section == 3) {
		if (indexPath.row == 0) {
			TextSwitchCell *cell = [self allocSwitchCell:tableView indexPath:indexPath];
			
			cell.label.text = @"All Categories";
			cell.checkbox.on = false;
			cell.checkbox.on = discount.allCategories;
			
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
