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

@interface EmployeeViewController ()

@end

@implementation EmployeeViewController

@synthesize employee;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:employee.name];
    if (employee.name.length == 0) {
        [self.navigationItem setTitle:@"Enter a Name"];
    }
    
    [[Storage getStorage] setManagedEmployee:employee];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[Storage getStorage] setManagedEmployee:nil];
    
    if (employee.name.length > 0) {
        [employee save];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    //TextFieldCell *cell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    //[[cell textField] becomeFirstResponder];
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
    } else if (section == 1) {
        return 2;
    }
    
    return 1;
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
            if (employee.code.length == 0) {
                cell.textLabel.text = @"Set Login Code";
            } else {
                cell.textLabel.text = @"Change Login Code";
            }
        } else if (indexPath.section == 1 && indexPath.row == 1) {
            if (employee.manager) {
                cell.textLabel.text = @"Remove from Manager Position";
            } else {
                cell.textLabel.text = @"Make Employee a Manager";
            }
        } else {
            cell.textLabel.text = @"Remove Employee";
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
        if (employee.code.length == 0) {
            [[LTHPasscodeViewController sharedUser] showForEnablingPasscodeInViewController:self];
        } else {
            [LTHPasscodeViewController setPasscode:employee.code];
            [[LTHPasscodeViewController sharedUser] showForChangingPasscodeInViewController:self];
        }
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
    } else if (indexPath.section == 2) {
        
    }
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    TextFieldCell *cell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.textField resignFirstResponder];
}

@end
