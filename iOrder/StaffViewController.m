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
#import "Employee.h"
#import "EmployeeViewController.h"

@interface StaffViewController () {
    Employee *newEmployee;
    NSArray *managers;
    NSArray *normal;
}

@end

@implementation StaffViewController

static NSComparisonResult (^staffComparator)(Employee *, Employee *) = ^(Employee *a, Employee *b) {
	return [a.name compare:b.name];
};

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshStaff:) forControlEvents:UIControlEventValueChanged];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEmployee:)]];
    
    [[Storage getStorage] addObserver:self forKeyPath:@"staff" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)reloadData {
    NSMutableArray *_managers = [[NSMutableArray alloc] init];
    NSMutableArray *_normal = [[NSMutableArray alloc] init];
    
    NSArray *staff = [Storage getStorage].staff;
    
    for (Employee *employee in staff) {
        if (employee.manager) {
            [_managers addObject:employee];
        } else {
            [_normal addObject:employee];
        }
    }
    
    managers = [_managers sortedArrayUsingComparator:staffComparator];
    normal = [_normal sortedArrayUsingComparator:staffComparator];
    
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [self reloadData];
    
    [[Storage getStorage] setManagedEmployee:nil];
    
    if (newEmployee) {
        [self refreshStaff:nil];
        newEmployee = nil;
    }
}

- (void)refreshStaff:(id)sender {
    [[Connection getConnection].socket sendEvent:@"get.staff" withData:nil];
}

- (void)addEmployee:(id)sender {
    newEmployee = [[Employee alloc] init];
    [self performSegueWithIdentifier:@"employee" sender:newEmployee];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"staff"]) {
        [self.refreshControl endRefreshing];
        [self reloadData];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"employee"]) {
        EmployeeViewController *vc = (EmployeeViewController *)[segue destinationViewController];
        vc.employee = (Employee *)sender;
    }
}

- (void)dealloc {
    @try {
        [[Storage getStorage] removeObserver:self forKeyPath:@"staff"];
    } @catch (NSException *e) {}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return managers.count;
    } else {
        return normal.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"basic";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Employee *employee;
    if (indexPath.section == 0) {
        employee = [managers objectAtIndex:indexPath.row];
    } else {
        employee = [normal objectAtIndex:indexPath.row];
    }
    cell.textLabel.text = employee.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Employee *employee;
    if (indexPath.section == 0) {
        employee = [managers objectAtIndex:indexPath.row];
    } else {
        employee = [normal objectAtIndex:indexPath.row];
    }
    
    [self performSegueWithIdentifier:@"employee" sender:employee];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Managers";
    } else {
        return @"Staff";
    }
}

@end
