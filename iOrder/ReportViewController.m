//
//  ReportViewController.m
//  iOrder
//
//  Created by Matej Kramny on 20/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "ReportViewController.h"
#import "Report.h"

@interface ReportViewController ()

@end

@implementation ReportViewController

@synthesize report;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.navigationItem setTitle:report._id];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
		return 2;
	}
	if (section == 1) {
		return report.tables.count;
	}
	
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
	
	if (indexPath.section == 0) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"detail" forIndexPath:indexPath];
		
		if (indexPath.row == 0) {
			cell.textLabel.text = @"Items Sold";
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", report.quantity];
		} else if (indexPath.row == 1) {
			cell.textLabel.text = @"Total Profit";
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%f", report.total];
		}
	} else if (indexPath.section == 1) {
		NSDictionary *table = [report.tables objectAtIndex:indexPath.row];
		
		cell = [tableView dequeueReusableCellWithIdentifier:@"table" forIndexPath:indexPath];
	}
    
    return cell;
}

@end
