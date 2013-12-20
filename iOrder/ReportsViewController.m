//
//  ReportsViewController.m
//  iOrder
//
//  Created by Matej Kramny on 15/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "ReportsViewController.h"
#import "Storage.h"
#import "Connection.h"
#import "Report.h"
#import "AppDelegate.h"
#import "ReportViewController.h"

@interface ReportsViewController () {
	NSDictionary *sections;
}

@end

@implementation ReportsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventEditingDidBegin];
	
	[[Storage getStorage] addObserver:self forKeyPath:@"reports" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	[self reload:nil];
	[self.refreshControl beginRefreshing];
}

- (void)dealloc {
	@try {
		[[Storage getStorage] removeObserver:self forKeyPath:@"reports"];
	} @catch (NSException *e) {}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"reports"]) {
		[self doSections];
		
		[self.tableView reloadData];
		[self.refreshControl endRefreshing];
	}
}

- (void)reload:(id)sender {
	[[[Connection getConnection] socket] sendEvent:@"get.reports" withData:nil];
}

- (void)doSections {
	NSArray *reports = [Storage getStorage].reports;
	NSMutableDictionary *_sections = [[NSMutableDictionary alloc] init];
	
	for (Report *report in reports) {
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"MMMM"];
		
		NSString *monthName = [dateFormat stringFromDate:report.created];
		if ([_sections objectForKey:monthName] == nil) {
			[_sections setObject:[[NSMutableArray alloc] init] forKey:monthName];
		}
		
		[[_sections objectForKey:monthName] addObject:report];
	}
	
	sections = [_sections copy];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"Report"]) {
		ReportViewController *vc = (ReportViewController *)[segue destinationViewController];
		vc.report = (Report *)sender;
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[sections allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSArray *keys = [sections allKeys];
	return [[sections objectForKey:[keys objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Report";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	NSArray *keys = [sections allKeys];
	Report *report = [[sections objectForKey:[keys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"EEEE dd"];
	cell.textLabel.text = [dateFormat stringFromDate:report.created];
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSArray *keys = [sections allKeys];
	return [keys objectAtIndex:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSArray *keys = [sections allKeys];
	Report *report = [[sections objectForKey:[keys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	
	[self performSegueWithIdentifier:@"Report" sender:report];
}

@end
