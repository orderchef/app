//
//  ReportViewController.m
//  iOrder
//
//  Created by Matej Kramny on 20/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "ReportViewController.h"
#import "Report.h"

@interface ReportViewController () {
	float normalTotal;
	int normalQuantity;
	float takeawayTotal;
	int takeawayQuantity;
	float deliveryTotal;
	int deliveryQuantity;
	
	float total;
	int quantity;
}

@end

@implementation ReportViewController

@synthesize reports;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	normalTotal = 0;
	normalQuantity = 0;
	takeawayTotal = 0;
	takeawayQuantity = 0;
	deliveryTotal = 0;
	deliveryQuantity = 0;
	total = 0;
	quantity = 0;
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"EEEE dd"];
	NSString *dayName = [dateFormat stringFromDate:[(Report *)[reports objectAtIndex:0] created]];
	
	[self.navigationItem setTitle:dayName];
	
	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"\uf02f " style:UIBarButtonItemStylePlain target:self action:@selector(print:)] animated:true];
	[self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{
																	NSFontAttributeName: [UIFont fontWithName:@"FontAwesome" size:24]
																	} forState:UIControlStateNormal];
	
	[self aggregate];
}

- (void)aggregate {
	for (Report *r in reports) {
		if (r.delivery) {
			deliveryTotal += r.total;
			deliveryQuantity += r.quantity;
		} else if (r.takeaway) {
			takeawayTotal += r.total;
			takeawayQuantity += r.quantity;
		} else {
			normalTotal += r.total;
			normalQuantity += r.quantity;
		}
		
		total += r.total;
		quantity += r.quantity;
	}
}

- (void)print:(id)sender {
	
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detail" forIndexPath:indexPath];
	
	int q = 0;
	float t = 0.f;
	
	if (indexPath.section == 0) {
		q = quantity;
		t = total;
	} else if (indexPath.section == 1) {
		q = normalQuantity;
		t = normalTotal;
	} else if (indexPath.section == 2) {
		q = takeawayQuantity;
		t = takeawayTotal;
	} else {
		q = deliveryQuantity;
		t = deliveryTotal;
	}
    
	if (indexPath.row == 0) {
		cell.textLabel.text = @"Items Sold";
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", q];
	} else if (indexPath.row == 1) {
		cell.textLabel.text = @"Total";
		cell.detailTextLabel.text = [NSString stringWithFormat:@"£%.2f", t];
	}
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"Grand Total";
		case 1:
			return @"Normal Tables";
		case 2:
			return @"Takeaway Tables";
		case 3:
			return @"Delivery Tables";
	}
	
	return nil;
}

@end
