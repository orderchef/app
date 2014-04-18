//
//  ManagerViewController.m
//  iOrder
//
//  Created by Matej Kramny on 09/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "ManagerViewController.h"
#import "TablesViewController.h"
#import <FontAwesome+iOS/FAImageView.h>

@interface ManagerViewController ()

@end

@implementation ManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@" \uf00d" style:UIBarButtonItemStylePlain target:self action:@selector(dismissView:)]];
	[self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{
																	 NSFontAttributeName: [UIFont fontWithName:@"FontAwesome" size:24]
																	 } forState:UIControlStateNormal];
	
	[[self navigationItem] setTitle:@"Manager"];
}

- (void)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
		return 2;
	} else if (section == 1) {
		return 4;
	}
	
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"basic";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	if (indexPath.section == 0) {
		cell.textLabel.font = [UIFont fontWithName:@"FontAwesome" size:18.f];
		if (indexPath.row == 0) {
			//FaBarChartO
			cell.textLabel.text = @"\uf080\tReports";
		} else if (indexPath.row == 1) {
			//FaUsers
			cell.textLabel.text = @"\uf0c0\tStaff";
		}
	} else if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			cell.textLabel.text = @"Tables";
		} else if (indexPath.row == 1) {
			cell.textLabel.text = @"Items";
		} else if (indexPath.row == 2) {
			cell.textLabel.text = @"Item Categories";
		} else if (indexPath.row == 3) {
			cell.textLabel.text = @"Discounts";
		}
	} else if (indexPath.section == 2) {
		cell.textLabel.font = [UIFont fontWithName:@"FontAwesome" size:18.f];
		cell.textLabel.text = @"\uf05a\tAbout";
	}
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *segue = @"";
    if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			segue = @"Reports";
		} else if (indexPath.row == 1) {
			segue = @"Staff";
		}
	} else if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			segue = @"Tables";
		} else if (indexPath.row == 1) {
			segue = @"Items";
		} else if (indexPath.row == 2) {
			segue = @"Categories";
		} else if (indexPath.row == 3) {
			segue = @"Discounts";
		}
	} else if (indexPath.section == 2) {
		segue = @"about";
	}
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"Tables"]) {
		TablesViewController *vc = (TablesViewController *)[segue destinationViewController];
		vc.manageEnabled = YES;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 2)
		return [@"OrderChef v" stringByAppendingString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
	
	return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
		UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)view;
		v.textLabel.textAlignment = NSTextAlignmentCenter;
		v.textLabel.font = [UIFont fontWithName:@"AppleGothic" size:14.f];
    }
}

@end
