//
//  BasketViewController.m
//  iOrder
//
//  Created by Matej Kramny on 28/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "BasketViewController.h"
#import "Table.h"
#import "Item.h"

@interface BasketViewController ()

@end

@implementation BasketViewController

@synthesize table;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.navigationItem.rightBarButtonItem setTarget:self];
	[self.navigationItem.rightBarButtonItem setAction:@selector(openMenu:)];
}

- (void)openMenu:(id) sender {
	[self performSegueWithIdentifier:@"openMenu" sender:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[[table item] allObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"basket";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	cell.textLabel.text = [[[[table item] allObjects] objectAtIndex:indexPath.row] name];
	
    return cell;
}

@end
