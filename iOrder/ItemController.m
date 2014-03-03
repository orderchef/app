//
//  CategoryViewController.m
//  iOrder
//
//  Created by Matej Kramny on 28/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "ItemController.h"
#import "TextFieldCell.h"
#import "Item.h"
#import "AppDelegate.h"
#import "ItemCategory.h"
#import "Storage.h"
#import "Connection.h"
#import "CategoriesViewController.h"

@interface ItemController () {
    ItemCategory *category;
    UITextField *name;
    UITextField *price;
	
	BOOL save;
}

@end

@implementation ItemController

@synthesize item;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	save = true;
	
	[self.navigationItem setTitle:item.name];
    if (item.name.length == 0) {
        [self.navigationItem setTitle:@"Enter a Name"];
    }
	if (item._id.length == 0) {
		[self.navigationItem setTitle:@"New Item"];
	} else {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"\uf014 " style:UIBarButtonItemStylePlain target:self action:@selector(deleteItem:)];
		[self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{
																		 NSFontAttributeName: [UIFont fontWithName:@"FontAwesome" size:24]
																		 } forState:UIControlStateNormal];
	}
	
    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	save = true;
	
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	if (save && item.name.length > 0 && item.category != nil && item.price != nil) {
        [item save];
    }
}

- (void)reloadData {
    [self.tableView reloadData];
}

- (void)nameChanged:(id)sender {
	[item setName:name.text];
    
    if (item.name.length == 0) {
        [self.navigationItem setTitle:@"Enter a Name"];
        //Check if is new item...
        if (item._id.length > 0) {
            [self.navigationItem setHidesBackButton:YES animated:NO];
        } else {
			self.navigationItem.title = @"New Item";
		}
    } else {
        [self.navigationItem setTitle:item.name];
        if (price.text.length > 0) {
			[self.navigationItem setHidesBackButton:NO animated:YES];
		} else {
			[self.navigationItem setHidesBackButton:YES animated:YES];
		}
    }
}

- (void)priceChanged:(id)sender {
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSNumber *p = [formatter numberFromString:price.text];
	
	[item setPrice:p];
    
    if (p.floatValue < 0.f || price.text.length == 0) {
        [self.navigationItem setTitle:@"Enter a Price"];
		
        if (item._id.length > 0) {
            [self.navigationItem setHidesBackButton:YES animated:NO];
        }
    } else {
        [self.navigationItem setTitle:item.name];
        
		if (name.text.length > 0) {
			[self.navigationItem setHidesBackButton:NO animated:YES];
		} else {
			[self.navigationItem setHidesBackButton:YES animated:YES];
		}
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"Categories"]) {
		save = false;
		CategoriesViewController *vc = (CategoriesViewController *)[segue destinationViewController];
		vc.item = item;
	}
}

- (void)deleteItem:(id)sender {
	save = false;
	[item deleteItem];
	[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:[item.name stringByAppendingString:@" Deleted"] detail:Nil hideAfter:0.5 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:self.parentViewController.view];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
		return 2;
	} if (section == 1) {
		return 1;
	}
	
	return 0;
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
                [cell.textField setPlaceholder:@"Item Name (required)"];
                [cell.textField setKeyboardType:UIKeyboardTypeDefault];
                name = cell.textField;
				[name setText:item.name];
				[name addTarget:self action:@selector(nameChanged:) forControlEvents:UIControlEventEditingChanged];
				name.delegate = self;
                break;
            case 1:
                [cell.textField setPlaceholder:@"Item Price (required)"];
                [cell.textField setKeyboardType:UIKeyboardTypeDecimalPad];
                price = cell.textField;
				float _price = [item.price floatValue];
				if (_price >= 0.f) {
					[price setText:[NSString stringWithFormat:@"%.2f", _price]];
				} else {
					[price setText:[NSString stringWithFormat:@""]];
				}
				[price addTarget:self action:@selector(priceChanged:) forControlEvents:UIControlEventEditingChanged];
                break;
        }
        
        return cell;
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"category"];
        
		if (item.category)
			cell.textLabel.text = item.category.name;
		else
			cell.textLabel.text = @"Choose Category (Required)";
        
        return cell;
    }
	
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        // category section
        [self performSegueWithIdentifier:@"Categories" sender:nil];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Item Details";
        case 1:
            return @"Item Category";
    }
    
    return nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    if (buttonIndex == 1) {
        category = [[ItemCategory alloc] init];
		item.category = category;
		[category setName:[[alertView textFieldAtIndex:0] text]];
		
        [category save];
        [self.refreshControl beginRefreshing];
        [[Storage getStorage] loadData];
        
        [self reloadData];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	
	return YES;
}

@end
