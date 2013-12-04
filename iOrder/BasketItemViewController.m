//
//  BasketItemViewController.m
//  iOrder
//
//  Created by Matej Kramny on 04/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "BasketItemViewController.h"
#import "Item.h"
#import "Table.h"

@interface BasketItemViewController () {
    UITapGestureRecognizer *dismissKeyboardGesture;
    bool keyboardIsOpen;
}

@end

@implementation BasketItemViewController

@synthesize item;
@synthesize table;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	Item *it = [item objectForKey:@"item"];
	[self.navigationItem setTitle:it.name];
	
	keyboardIsOpen = false;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"detail";
    UITableViewCell *cell;
	
	if (indexPath.section == 0) {
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
		
	} else if (indexPath.section == 1) {
		// notes
		cell = [tableView dequeueReusableCellWithIdentifier:@"notes" forIndexPath:indexPath];
		if (!cell) {
            cell = [[TextareaCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notes"];
        }
		
        [[(TextareaCell *)cell textField] setText:[item objectForKey:@"notes"]];
        [[(TextareaCell *)cell textField] setDelegate:(TextareaCell<UITextViewDelegate> *)cell];
        [(TextareaCell *)cell setDelegate:self];
	}
	
	return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return 100.f;
    }
    
    return 44.f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 1) {
		return @"Item-specific notes";
	}
	
	return nil;
}

#pragma mark - TextfieldDelegate methods

- (void)dismissKeyboard:(id)sender {
    TextareaCell *cell = (TextareaCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    [[cell textField] resignFirstResponder];
}

- (void)textFieldDidBeginEditing {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    dismissKeyboardGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    dismissKeyboardGesture.cancelsTouchesInView = YES;
    
    [self.tableView addGestureRecognizer:dismissKeyboardGesture];
    
    keyboardIsOpen = true;
}

- (void)textFieldDidEndEditing {
    keyboardIsOpen = false;
    
    TextareaCell *cell = (TextareaCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
	
	int index = [[table items] indexOfObject:item];
	NSMutableDictionary *dict = [item mutableCopy];
	[dict setObject:[cell.textField text] forKey:@"notes"];
	NSMutableArray *its = [[table items] mutableCopy];
	[its replaceObjectAtIndex:index withObject:[dict copy]];
	[table setItems:[its copy]];
	
	// refresh
	item = [[table items] objectAtIndex:index];
	[table save];
	
    @try {
        [self.tableView removeGestureRecognizer:dismissKeyboardGesture];
    }
    @catch (NSException *exception) {}
    @finally {
        dismissKeyboardGesture = nil;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (keyboardIsOpen) {
        [self dismissKeyboard:nil];
    }
}


@end
