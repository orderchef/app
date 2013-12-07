//
//  EditTableViewController.m
//  iOrder
//
//  Created by Matej Kramny on 06/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "EditTableViewController.h"
#import "TextFieldCell.h"
#import "Table.h"

@interface EditTableViewController ()

@end

@implementation EditTableViewController

@synthesize table;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.navigationItem setTitle:table.name];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[table save];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"Table Name";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	TextFieldCell *cell = (TextFieldCell *)[tableView cellForRowAtIndexPath:indexPath];
	[[cell textField] becomeFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *textCellIdentifier = @"text";
	
    TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:textCellIdentifier forIndexPath:indexPath];
	if (!cell) {
		cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:textCellIdentifier];
	}
    
	[[cell textField] setText:table.name];
	[[cell textField] setPlaceholder:@"Table Name"];
	[[cell textField] addTarget:self action:@selector(titleChanged:) forControlEvents:UIControlEventEditingChanged];
	
    return cell;
}

- (void)titleChanged:(id)sender {
	TextFieldCell *cell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	[self.navigationItem setTitle:cell.textField.text];
	[table setName:cell.textField.text];
}

@end
