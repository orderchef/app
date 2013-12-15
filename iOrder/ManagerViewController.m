//
//  ManagerViewController.m
//  iOrder
//
//  Created by Matej Kramny on 09/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "ManagerViewController.h"

@interface ManagerViewController ()

@end

@implementation ManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(dismissView:)]];
}

- (void)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
		return 3;
	}
	
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"basic";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			cell.textLabel.text = @"Items";
		} else if (indexPath.row == 1) {
			cell.textLabel.text = @"Staff";
		} else if (indexPath.row == 2) {
			cell.textLabel.text = @"Reports";
		}
	} else if (indexPath.section == 1) {
		cell.textLabel.text = @"About";
	}
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			[self performSegueWithIdentifier:@"Items" sender:nil];
		} else if (indexPath.row == 1) {
			[self performSegueWithIdentifier:@"Staff" sender:nil];
		} else if (indexPath.row == 2) {
			[self performSegueWithIdentifier:@"Reports" sender:nil];
		}
	} else if (indexPath.section == 1) {
		[self performSegueWithIdentifier:@"about" sender:nil];
	}
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
