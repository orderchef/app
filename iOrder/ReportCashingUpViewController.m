//
//  ReportCashingUpViewController.m
//  OrderChef
//
//  Created by Matej Kramny on 21/05/2014.
//  Copyright (c) 2014 Matej Kramny. All rights reserved.
//

#import "ReportCashingUpViewController.h"
#import "AppDelegate.h"
#import "Connection.h"
#import "ReportEditCashupViewController.h"

@interface ReportCashingUpViewController () {
	NSArray *cashups;
	NSDictionary *aggregate;
	bool editing;
}

@end

@implementation ReportCashingUpViewController

@synthesize dateRange;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	editing = false;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:kReportsNotificationName object:nil];
	
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(refreshEvents:) forControlEvents:UIControlEventValueChanged];
	
	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Print" style:UIBarButtonItemStylePlain target:self action:@selector(printReport:)]];
	[self.navigationItem setTitle:@"Cash Report"];
	
	[self refreshEvents:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (editing) {
		editing = false;
		
		[self refreshEvents:nil];
	}
}

- (void)dealloc {
	@try {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:kReportsNotificationName object:nil];
	} @catch (NSException *exception) {}
}

- (void)printReport:(id)sender {
	__block NSMutableString *report = [[NSMutableString alloc] init];
	
	[report appendString:@"Cashing Up Report\n"];
	
	NSDictionary *dict = @{
						   @"cash": @"Cash",
						   @"card": @"Card",
						   @"voucher": @"Voucher",
						   @"pettyCash": @"Petty Cash",
						   @"labour": @"Labour",
						   @"tips": @"Tips",
						   @"justEat": @"Just Eat"
						   };
	
	for (NSString *key in [dict allKeys]) {
		NSNumber *number = [aggregate objectForKey:key];
		NSString *numberString = [NSString stringWithFormat:@"%.2f GBP", [number floatValue]];
		
		[report appendFormat:@"%@: %@\n", [dict objectForKey:key], numberString];
	}
	
	[report appendFormat:@"\nGross: %@\n", [NSString stringWithFormat:@"%.2f GBP", [[aggregate objectForKey:@"gross"] floatValue]]];
	
	[[Connection getConnection].socket sendEvent:@"print" withData:@{
																	 @"data": report,
																	 @"receiptPrinter": [NSNumber numberWithBool:true],
																	 @"printDate": [NSNumber numberWithBool:true]
																	 }];
}

- (void)refreshEvents:(id)sender {
	[self.refreshControl beginRefreshing];
	[[[Connection getConnection] socket] sendEvent:@"get.report cashing up" withData:
	 @{
	   @"from": [NSNumber numberWithInt:(int)[[dateRange objectAtIndex:0] timeIntervalSince1970]],
	   @"to": [NSNumber numberWithInt:(int)[[dateRange objectAtIndex:1] timeIntervalSince1970]]
	   }];
}

- (void)didReceiveNotification:(NSNotification *)notification {
	NSDictionary *reportData = [notification userInfo];
	NSString *type = [reportData objectForKey:@"type"];
	
	if ([type isEqualToString:@"cashingUp"]) {
		cashups = [reportData objectForKey:@"cashups"];
		aggregate = [reportData objectForKey:@"aggregate"];
		
		[self.refreshControl endRefreshing];
		[self.tableView reloadData];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"openCashup"]) {
		ReportEditCashupViewController *vc = (ReportEditCashupViewController *)[segue destinationViewController];
		
		editing = true;
		vc.justEat = false;
		
		if ([sender isKindOfClass:[NSDictionary class]]) {
			NSDictionary *cashReport = (NSDictionary *)sender;
			
			vc.cashReport = [cashReport mutableCopy];
		}
		if ([sender isKindOfClass:[NSNumber class]] && [(NSNumber *)sender boolValue] == true) {
			// Is JustEat
			vc.justEat = true;
		}
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) return 2;
	if (section == 1) return 7;
	if (section == 2) return 1;
	if (section == 3) return [cashups count];
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detail" forIndexPath:indexPath];
	
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			cell.textLabel.text = @"Add Cash Report";
		} else {
			cell.textLabel.text = @"Add JustEat Receipt";
		}
		cell.textLabel.textAlignment = NSTextAlignmentCenter;
		cell.detailTextLabel.text = nil;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else if (indexPath.section == 1) {
		NSString *key;
		
		switch (indexPath.row) {
			case 0:
				key = @"cash";
				cell.textLabel.text = @"Cash";
				break;
			case 1:
				key = @"card";
				cell.textLabel.text = @"Card";
				break;
			case 2:
				key = @"voucher";
				cell.textLabel.text = @"Voucher";
				break;
			case 3:
				key = @"pettyCash";
				cell.textLabel.text = @"Petty Cash";
				break;
			case 4:
				key = @"labour";
				cell.textLabel.text = @"Labour";
				break;
			case 5:
				key = @"tips";
				cell.textLabel.text = @"Tips";
				break;
			case 6:
				key = @"justEat";
				cell.textLabel.text = @"Just Eat";
				break;
		}
		
		NSNumber *number = [aggregate objectForKey:key];
		if (!(number == NULL || [number isKindOfClass:[NSNull class]])) {
			cell.detailTextLabel.text = [NSString stringWithFormat:@"£%.2f", [number floatValue]];
		}
		cell.accessoryType = UITableViewCellAccessoryNone;
	} else if (indexPath.section == 2) {
		cell.textLabel.text = @"Gross";
		cell.detailTextLabel.text = [NSString stringWithFormat:@"£%.2f", [[aggregate objectForKey:@"gross"] floatValue]];
		cell.accessoryType = UITableViewCellAccessoryNone;
	} else if (indexPath.section == 3) {
		NSDictionary *cashup = [cashups objectAtIndex:indexPath.row];
		NSDate *created = [NSDate dateWithTimeIntervalSince1970:[[cashup objectForKey:@"created"] longValue]];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		
		NSString *pre = @"Cash ";
		NSString *dateFormat = @"dd/MM/YYYY hh:mm";
		if ([cashup objectForKey:@"isJustEat"] && [[cashup objectForKey:@"isJustEat"] boolValue]) {
			pre = @"JustEat ";
		}
		
		[dateFormatter setDateFormat:dateFormat];
		cell.textLabel.text = [NSString stringWithFormat:@"%@%@", pre, [dateFormatter stringFromDate:created]];
		cell.detailTextLabel.text = [NSString stringWithFormat:@"£%.2f", [[cashup objectForKey:@"total"] floatValue]];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 0) {
		[self performSegueWithIdentifier:@"openCashup" sender:nil];
		return;
	} else if (indexPath.section == 0 && indexPath.row == 1) {
		[self performSegueWithIdentifier:@"openCashup" sender:[NSNumber numberWithBool:true]];
		return;
	}
	
	if (indexPath.section == 3) {
		[self performSegueWithIdentifier:@"openCashup" sender:[cashups objectAtIndex:indexPath.row]];
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 1) {
		return @"Aggregated Cash Report";
	}
	
	if (section == 3) {
		return @"Reports Involved";
	}
	
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 2) {
		return @"Gross = Cash + Card + Petty Cash + Labour + Voucher + JustEat";
	}
	
	return nil;
}

@end
