//
//  ReportDateViewController.m
//  OrderChef
//
//  Created by Matej Kramny on 25/04/2014.
//  Copyright (c) 2014 Matej Kramny. All rights reserved.
//

#import "ReportDateViewController.h"

@interface ReportDateViewController ()

@end

@implementation ReportDateViewController

@synthesize startDate, endDate;

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}

@end
