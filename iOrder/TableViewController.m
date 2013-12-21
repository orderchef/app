//
//  EditTableViewController.m
//  iOrder
//
//  Created by Matej Kramny on 06/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "TableViewController.h"
#import "TextFieldCell.h"
#import "Table.h"
#import "AppDelegate.h"

@interface TableViewController () {
	UISwitch *takeaway;
	UISwitch *delivery;
	UILabel *takeawayLabel;
	UILabel *deliveryLabel;
	UIView *takeawayFooter;
	UIView *deliveryFooter;
}

@end

@implementation TableViewController

@synthesize table;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if (table._id.length == 0) {
		[self.navigationItem setTitle:@"New Table"];
	} else {
		[self.navigationItem setTitle:table.name];
		
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"\uf014 " style:UIBarButtonItemStylePlain target:self action:@selector(deleteTable:)];
		[self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{
																		 NSFontAttributeName: [UIFont fontWithName:@"FontAwesome" size:24]
																		 } forState:UIControlStateNormal];
		
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	if (table.name.length > 0)
		[table save];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0)
		return @"Table Name";
	
	return nil;
}

- (void)deleteTable:(id)sender {
	// Delete
	[table deleteTable];
	[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:[table.name stringByAppendingString:@" Deleted"] detail:Nil hideAfter:0.5 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:self.parentViewController.view];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		TextFieldCell *cell = (TextFieldCell *)[tableView cellForRowAtIndexPath:indexPath];
		[[cell textField] becomeFirstResponder];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
		return 1;
	}
	
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *textCellIdentifier = @"text";
	
	if (indexPath.section == 0) {
		TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:textCellIdentifier forIndexPath:indexPath];
		if (!cell) {
			cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:textCellIdentifier];
		}
		
		[[cell textField] setText:table.name];
		[[cell textField] setPlaceholder:@"Table Name"];
		[[cell textField] addTarget:self action:@selector(titleChanged:) forControlEvents:UIControlEventEditingChanged];
		
		return cell;
	}
	
	return nil;
}

- (void)titleChanged:(id)sender {
	TextFieldCell *cell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	[table setName:cell.textField.text];
    
    if (table.name.length == 0 && table._id.length > 0) {
        [self.navigationItem setTitle:@"Enter a Name"];
        [self.navigationItem setHidesBackButton:YES animated:NO];
    } else {
		if (table.name.length == 0 && table._id.length == 0) {
			[self.navigationItem setTitle:@"New Table"];
		} else {
			[self.navigationItem setTitle:table.name];
			
		}
		
        [self.navigationItem setHidesBackButton:NO animated:YES];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	if (section == 1) {
		if (!takeaway) {
			takeaway = [[UISwitch alloc] init];
			[takeaway addTarget:self action:@selector(takeawayToggle:) forControlEvents:UIControlEventValueChanged];
			[takeaway setFrame:CGRectMake(self.tableView.frame.size.width - takeaway.frame.size.width - 20, 0, takeaway.frame.size.width, takeaway.frame.size.height)];
		}
		if (!takeawayLabel) {
			takeawayLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 29.f)];
			[takeawayLabel setText:@"Takeaway Table"];
		}
		
		if (!takeawayFooter) {
			takeawayFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 29.f)];
			[takeawayFooter addSubview:takeaway];
			[takeawayFooter addSubview:takeawayLabel];
		}
		
		[takeaway setOn:table.takeaway];
		
		return takeawayFooter;
	} else if (section == 2) {
		if (!delivery) {
			delivery = [[UISwitch alloc] init];
			[delivery addTarget:self action:@selector(deliveryToggle:) forControlEvents:UIControlEventValueChanged];
			[delivery setFrame:CGRectMake(self.tableView.frame.size.width - delivery.frame.size.width - 20, 0, delivery.frame.size.width, delivery.frame.size.height)];
		}
		if (!deliveryLabel) {
			deliveryLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 29.f)];
			[deliveryLabel setText:@"Delivery Table"];
		}

		if (!deliveryFooter) {
			deliveryFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 29.f)];
			[deliveryFooter addSubview:delivery];
			[deliveryFooter addSubview:deliveryLabel];
		}
		
		[delivery setOn:table.delivery];

		return deliveryFooter;
	}
	
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (section == 1 || section == 2) {
		return 29.f;
	}
	
	return 0.f;
}

- (void)takeawayToggle:(id)sender {
	[table setTakeaway:takeaway.isOn];
}

- (void)deliveryToggle:(id)sender {
	[table setDelivery:delivery.isOn];
}

@end
