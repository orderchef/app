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
#import "AppDelegate.h"

@interface ReportsViewController () {
	NSDictionary *sections;
}

@end

@implementation ReportsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[[Storage getStorage] addObserver:self forKeyPath:@"reports" options:NSKeyValueObservingOptionNew context:nil];
	if (sections == nil) {
		[self reload:nil];
		[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:@"Loading..." detail:Nil hideAfter:0.5 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:self.view];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	@try {
		[[Storage getStorage] removeObserver:self forKeyPath:@"reports"];
	} @catch (NSException *e) {}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"reports"]) {
		if ([Storage getStorage].reports == nil) return;
		
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
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	for (Report *report in reports) {
		[dateFormat setDateFormat:@"MMMM YYYY"];
		NSString *monthName = [dateFormat stringFromDate:report.created];
		
		if ([_sections objectForKey:monthName] == nil) {
			[_sections setObject:[[NSMutableDictionary alloc] init] forKey:monthName];
		}
		
		[dateFormat setDateFormat:@"EEEE dd"];
		NSString *dayName = [dateFormat stringFromDate:report.created];
		
		if ([[_sections objectForKey:monthName] objectForKey:dayName] == nil) {
			[[_sections objectForKey:monthName] setObject:[[NSMutableArray alloc] init] forKey:dayName];
		}
		
		[[[_sections objectForKey:monthName] objectForKey:dayName] addObject:report];
	}
	
	sections = [_sections copy];
	[Storage getStorage].reports = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"Report"]) {
		ReportViewController *vc = (ReportViewController *)[segue destinationViewController];
		vc.reports = (NSMutableArray *)sender;
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
    
	NSString *key = [[sections allKeys] objectAtIndex:indexPath.section];
	cell.textLabel.text = [[[sections objectForKey:key] allKeys] objectAtIndex:indexPath.row];
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSArray *keys = [sections allKeys];
	return [keys objectAtIndex:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *key = [[sections allKeys] objectAtIndex:indexPath.section];
	NSMutableArray *reports = [[sections objectForKey:key] objectForKey:[[[sections objectForKey:key] allKeys] objectAtIndex:indexPath.row]];
	
	[self performSegueWithIdentifier:@"Report" sender:reports];
}

@end
