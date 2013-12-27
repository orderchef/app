//
//  CategoryViewController.m
//  iOrder
//
//  Created by Matej Kramny on 21/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "CategoryViewController.h"
#import "TextFieldCell.h"
#import "ItemCategory.h"
#import "AppDelegate.h"
#import "PrintersViewController.h"

@interface CategoryViewController () {
	BOOL save;
}

@end

@implementation CategoryViewController

@synthesize category;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	save = true;
	
	[self.navigationItem setTitle:category.name];
	if (category.name.length == 0) {
        [self.navigationItem setTitle:@"New Category"];
    }
	
	if (category._id.length > 0) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"\uf014 " style:UIBarButtonItemStylePlain target:self action:@selector(deleteCategory:)];
		[self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{
																		 NSFontAttributeName: [UIFont fontWithName:@"FontAwesome" size:24]
																		 } forState:UIControlStateNormal];
	}

}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	if (save && category.name.length > 0) {
        [category save];
    }
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (!save) save = !save;
}

- (void)titleChanged:(id)sender {
	TextFieldCell *cell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	[category setName:cell.textField.text];
    
    if (category.name.length == 0 && category._id.length > 0) {
        [self.navigationItem setTitle:@"Enter a Name"];
        [self.navigationItem setHidesBackButton:YES animated:NO];
    } else {
		if (category.name.length == 0 && category._id.length == 0) {
			[self.navigationItem setTitle:@"New Category"];
		} else {
			[self.navigationItem setTitle:category.name];
			
		}
		
        [self.navigationItem setHidesBackButton:NO animated:YES];
    }
}

- (void)deleteCategory:(id)sender {
	// Delete
	save = false;
	[category deleteCategory];
	
	[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:[category.name stringByAppendingString:@" Deleted"] detail:Nil hideAfter:0.5 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:self.parentViewController.view];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"printers"]) {
		PrintersViewController *vc = (PrintersViewController *)[segue destinationViewController];
		vc.category = category;
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"text";
    
	if (indexPath.section == 0) {
		TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
		if (!cell) {
			cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		}
		
		cell.textField.placeholder = @"Category Name (required)";
		cell.textField.text = category.name;
		[cell.textField addTarget:self action:@selector(titleChanged:) forControlEvents:UIControlEventEditingChanged];
		
		return cell;
	} else if (indexPath.section == 1) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basic" forIndexPath:indexPath];
		
		cell.textLabel.text = @"Select Printers";
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
		
		return cell;
	}
	
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		TextFieldCell *cell = (TextFieldCell *)[tableView cellForRowAtIndexPath:indexPath];
		[cell.textField becomeFirstResponder];
	} else if (indexPath.section == 1) {
		[self performSegueWithIdentifier:@"printers" sender:nil];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Category Details";
	}
	if (section == 1) {
		return @"Printers";
	}
	
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 1) {
		return @"When printing the order, the order will be printed to the selected printers (for each category).\nWhen no printers are selected, the order will be sent to all printers";
	}
	
	return nil;
}

@end
