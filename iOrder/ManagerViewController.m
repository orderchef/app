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
		return 3;
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
			cell.textLabel.text = @"\uf080 Reports";
		} else if (indexPath.row == 1) {
			//FaUsers
			cell.textLabel.text = @"\uf0c0 Staff";
		}
	} else if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			cell.textLabel.text = @"Tables";
		} else if (indexPath.row == 1) {
			cell.textLabel.text = @"Items";
		} else if (indexPath.row == 2) {
			cell.textLabel.text = @"Item Categories";
		}
	} else if (indexPath.section == 2) {
		cell.textLabel.font = [UIFont fontWithName:@"FontAwesome" size:18.f];
		cell.textLabel.text = @"\uf05a About";
	}
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			[self performSegueWithIdentifier:@"Reports" sender:nil];
		} else if (indexPath.row == 1) {
			[self performSegueWithIdentifier:@"Staff" sender:nil];
		}
	} else if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			[self performSegueWithIdentifier:@"Tables" sender:nil];
		} else if (indexPath.row == 1) {
			[self performSegueWithIdentifier:@"Items" sender:nil];
		} else if (indexPath.row == 2) {
			[self performSegueWithIdentifier:@"Categories" sender:nil];
		}
	} else if (indexPath.section == 2) {
		[self performSegueWithIdentifier:@"about" sender:nil];
	}
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"Tables"]) {
		TablesViewController *vc = (TablesViewController *)[segue destinationViewController];
		vc.manageEnabled = YES;
	}
}

@end
