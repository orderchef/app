//
//  CategoryViewController.m
//  iOrder
//
//  Created by Matej Kramny on 28/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "CategoryViewController.h"
#import "TextFieldCell.h"
#import "Item.h"
#import "AppDelegate.h"
#import "ItemCategory.h"
#import "Storage.h"
#import "Connection.h"

@interface CategoryViewController () {
    NSArray *categories;
    ItemCategory *category;
}

@end

@implementation CategoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.navigationItem.leftBarButtonItem setTarget:self];
	[self.navigationItem.leftBarButtonItem setAction:@selector(closeView:)];
	[self.navigationItem.rightBarButtonItem setTarget:self];
	[self.navigationItem.rightBarButtonItem setAction:@selector(saveItem:)];
    
    [self reloadData];
}

- (void)reloadData {
    categories = [[Storage getStorage] categories];
    
    [self.tableView reloadData];
}

- (void)closeView:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveItem:(id)sender {
    Storage *storage = [Storage getStorage];
    Item *item = [[Item alloc] init];
    [[storage items] addObject:item];
    
    NSString *name = [(TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] textField].text;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *price = [formatter numberFromString:[(TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] textField].text];
    
    [item setName:name];
    [item setCategory:category];
    [item setPrice:price];
    
    [item save];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 2 : [categories count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"text";
    
    if (indexPath.section == 0) {
        TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if (!cell){
            cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        switch (indexPath.row) {
            case 0:
                [cell.textField setPlaceholder:@"Item Name"];
                [cell.textField setKeyboardType:UIKeyboardTypeDefault];
                break;
            case 1:
                [cell.textField setPlaceholder:@"Item Price"];
                [cell.textField setKeyboardType:UIKeyboardTypeDecimalPad];
                break;
        }
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"category"];
        
        if (indexPath.row >= [categories count]) {
            cell.textLabel.text = @"Create Category...";
        } else {
            cell.textLabel.text = [[categories objectAtIndex:indexPath.row] name];
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        // category section
        if (indexPath.row >= [categories count]) {
            // Create a category..
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Create Category" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
            [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [alertView show];
        } else {
            category = [categories objectAtIndex:indexPath.row];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return nil;
        case 1:
            return @"Item Category";
    }
    
    return nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    if (buttonIndex == 1) {
        category = [[ItemCategory alloc] init];
		[category setName:[[alertView textFieldAtIndex:0] text]];
		
        [category save];
        
        [self reloadData];
    }
}

@end
