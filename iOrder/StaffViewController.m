//
//  StaffViewController.m
//  iOrder
//
//  Created by Matej Kramny on 09/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "StaffViewController.h"
#import "Storage.h"
#import "Connection.h"
#import "Staff.h"
#import "EmployeeViewController.h"

@interface StaffViewController () {
    Staff *newEmployee;
}

@end

@implementation StaffViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshStaff:) forControlEvents:UIControlEventValueChanged];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEmployee:)]];
    
    [[Storage getStorage] addObserver:self forKeyPath:@"staff" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
    
    if (newEmployee) {
        [self refreshStaff:nil];
        newEmployee = nil;
    }
}

- (void)refreshStaff:(id)sender {
    [[Connection getConnection].socket sendEvent:@"get.staff" withData:nil];
}

- (void)addEmployee:(id)sender {
    newEmployee = [[Staff alloc] init];
    [self performSegueWithIdentifier:@"employee" sender:newEmployee];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"staff"]) {
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    }
}

- (int)numberOfManagers {
    NSArray *staff = [Storage getStorage].staff;
    int managers = 0;
    
    for (Staff *employee in staff) {
        if (employee.manager) {
            managers++;
        }
    }
    return managers;
}

- (Staff *)getEmployeeForIndexPath:(NSIndexPath *)indexPath {
    int managers = [self numberOfManagers];
    int row = indexPath.row;
    if (indexPath.section == 1) {
        row += managers;
    }
    
    return [[Storage getStorage].staff objectAtIndex:row];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"employee"]) {
        EmployeeViewController *vc = (EmployeeViewController *)[segue destinationViewController];
        vc.employee = (Staff *)sender;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *staff = [Storage getStorage].staff;
    
    int managers = [self numberOfManagers];
    if (section == 0) {
        return managers;
    } else {
        return staff.count - managers;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"basic";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Staff *employee = [self getEmployeeForIndexPath:indexPath];
    cell.textLabel.text = employee.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"employee" sender:[self getEmployeeForIndexPath:indexPath]];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Managers";
    } else {
        return @"Staff";
    }
}

@end
