//
//  EmployeeViewController.m
//  iOrder
//
//  Created by Matej Kramny on 09/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "EmployeeViewController.h"
#import "Staff.h"
#import "TextFieldCell.h"
#import "LTHPasscodeViewController.h"
#import "AppDelegate.h"
#import <FontAwesome+iOS/NSString+FontAwesome.h>

@interface EmployeeViewController () {
	BOOL save;
}

@end

@implementation EmployeeViewController

@synthesize employee;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	save = true;
	
    [self.navigationItem setTitle:employee.name];
    if (employee.name.length == 0) {
        [self.navigationItem setTitle:@"Enter a Name"];
    }
	
	if (employee._id.length > 0) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"\uf014 " style:UIBarButtonItemStylePlain target:self action:@selector(deleteEmployee:)];
		[self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{
																		 NSFontAttributeName: [UIFont fontWithName:@"FontAwesome" size:24]
																		 } forState:UIControlStateNormal];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (save && employee.name.length > 0) {
        [employee save];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
	// Used to set passcode lock to the managedEmployee and not the employee currently logged in..
    [[Storage getStorage] setManagedEmployee:employee];
    //TextFieldCell *cell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    //[[cell textField] becomeFirstResponder];
}

- (void)deleteEmployee:(id)sender {
	save = false;
	[employee remove];
	[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:[employee.name stringByAppendingString:@" Deleted"] detail:Nil hideAfter:0.5 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:self.parentViewController.view];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 2;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __unused static NSString *CellIdentifier = @"text";
    __unused static NSString *ButtonCellIdentifier = @"button";
    
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if (!cell) {
            cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [[(TextFieldCell *)cell textField] setText:employee.name];
        [[(TextFieldCell *)cell textField] setPlaceholder:@"Employee Name (required)"];
        [[(TextFieldCell *)cell textField] addTarget:self action:@selector(nameChanged:) forControlEvents:UIControlEventEditingChanged];
    } else if (indexPath.section >= 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:ButtonCellIdentifier forIndexPath:indexPath];
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        
        if (indexPath.section == 1 && indexPath.row == 0) {
			cell.textLabel.font = [UIFont fontWithName:@"FontAwesome" size:cell.textLabel.font.pointSize];
            if (employee.code.length == 0) {
                cell.textLabel.text = @"\uf084 Set Login Code";
            } else {
                cell.textLabel.text = @"\uf084 Change Login Code";
            }
        } else if (indexPath.section == 1 && indexPath.row == 1) {
            if (employee.manager) {
                cell.textLabel.text = @"Remove from Manager Position";
            } else {
                cell.textLabel.text = @"Make Employee a Manager";
            }
        }
    }
    
    return cell;
}

- (void)nameChanged:(id)sender {
	TextFieldCell *cell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	[employee setName:cell.textField.text];
    
    if (employee.name.length == 0) {
        [self.navigationItem setTitle:@"Enter a Name"];
        //Check if is new employee...
        if (employee._id.length > 0) {
            [self.navigationItem setHidesBackButton:YES animated:NO];
        }
    } else {
        [self.navigationItem setTitle:employee.name];
        [self.navigationItem setHidesBackButton:NO animated:YES];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Details";
    } else if (section == 1) {
        return @"Actions";
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        TextFieldCell *cell = (TextFieldCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell.textField becomeFirstResponder];
    }
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        [[LTHPasscodeViewController sharedUser] showForEnablingPasscodeInViewController:self];
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        if ([employee._id isEqualToString:[Storage getStorage].employee._id]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable Downgrade Yourself" message:@"Sorry, Please have one of the other Managers downgrade you." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [alert show];
            
            return;
        }
        
        [employee setManager:!employee.manager];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (employee.manager) {
            cell.textLabel.text = @"Remove from Manager Position";
        } else {
            cell.textLabel.text = @"Make Employee a Manager";
        }
    }
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    TextFieldCell *cell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.textField resignFirstResponder];
}

@end
