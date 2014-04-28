//
//  ReportOrdersViewController.m
//  OrderChef
//
//  Created by Matej Kramny on 23/04/2014.
//  Copyright (c) 2014 Matej Kramny. All rights reserved.
//

#import "ReportOrdersViewController.h"

@interface ReportOrdersViewController ()

@end

@implementation ReportOrdersViewController

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"viewOrdersForDate"]) {
		
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return 1;
	}
	
	if (section == 1) {
		return 2;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	__unused static NSString *leftDetailCellID = @"leftDetail";
	__unused static NSString *rightDetailCellID = @"rightDetail";
	__unused static NSString *basicCellID = @"basic";
	
	NSString *cellID;
	if (indexPath.section == 0) {
		cellID = basicCellID;
	}
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
	
	if (indexPath.section == 0) {
		cell.textLabel.text = @"Today";
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		NSCalendar *cal = [NSCalendar currentCalendar];
		NSDate *now = [NSDate date];
		NSDateComponents *comps = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:now];
		
		NSDate *today_start = [cal dateFromComponents:comps];
		NSDate *today_end = [NSDate dateWithTimeIntervalSince1970:((int)[today_start timeIntervalSince1970] + (60 * 60 * 24))];
		
		[self performSegueWithIdentifier:@"viewOrdersForDate" sender:@[today_start, today_end]];
	}
}

@end
