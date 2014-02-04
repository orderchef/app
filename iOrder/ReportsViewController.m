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
#import "AppDelegate.h"
#import "ReportViewController.h"
#import "AppDelegate.h"

@interface ReportsViewController () {
	NSDictionary *sections;
	NSArray *groups;
}

@end

@implementation ReportsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:kReportsNotificationName object:nil];
	[[Connection getConnection].socket sendEvent:@"get.reports" withData:nil];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (sections == nil) {
		[self reload:nil];
		[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:@"Loading..." detail:Nil hideAfter:0.5 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:self.view];
	}
}

- (void)didReceiveNotification:(NSNotification *)notification {
	if ([[notification name] isEqualToString:kReportsNotificationName]) {
		NSDictionary *report = [notification userInfo];
		[self doSections:[report objectForKey:@"aggregated"]];
		
		[self.tableView reloadData];
		[self.refreshControl endRefreshing];
	}
}

- (void)reload:(id)sender {
	[[[Connection getConnection] socket] sendEvent:@"get.reports" withData:nil];
}

- (void)doSections:(NSDictionary *)report {
	NSArray *orders = [report objectForKey:@"orders"];
	
	NSMutableDictionary *_sections = [[NSMutableDictionary alloc] init];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	for (NSDictionary *order in orders) {
		[dateFormat setDateFormat:@"yyyy MMMM"];
		NSDate *created = [NSDate dateWithTimeIntervalSince1970:[[order objectForKey:@"time"] intValue]];
		NSString *monthName = [dateFormat stringFromDate:created];
		
		if ([_sections objectForKey:monthName] == nil) {
			[_sections setObject:[[NSMutableDictionary alloc] init] forKey:monthName];
		}
		
		[dateFormat setDateFormat:@"EEEE dd"];
		NSString *dayName = [dateFormat stringFromDate:created];
		
		if ([[_sections objectForKey:monthName] objectForKey:dayName] == nil) {
			[[_sections objectForKey:monthName] setObject:[[NSMutableArray alloc] init] forKey:dayName];
		}
		
		[[[_sections objectForKey:monthName] objectForKey:dayName] addObject:order];
	}
	
	sections = [_sections copy];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"Report"]) {
		ReportViewController *vc = (ReportViewController *)[segue destinationViewController];
		vc.reports = (NSArray *)sender;
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
	NSArray *report = [[sections objectForKey:key] objectForKey:[[[sections objectForKey:key] allKeys] objectAtIndex:indexPath.row]];
	
	[self performSegueWithIdentifier:@"Report" sender:report];
}

@end
