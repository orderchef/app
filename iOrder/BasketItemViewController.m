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
	
	UIStepper *quantityStepper;
	UILabel *quantityLabel;
	
	int quantity;
	NSString *notes;
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
	
	quantity = [[item objectForKey:@"quantity"] intValue];
	notes = [item objectForKey:@"notes"];
	
	keyboardIsOpen = false;
    
}

- (void)saveItem {
	TextareaCell *cell = (TextareaCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
	int index = [[table items] indexOfObject:item];
	
	NSMutableDictionary *dict = [item mutableCopy];
	[dict setObject:[cell.textField text] forKey:@"notes"];
	[dict setObject:[NSNumber numberWithInteger:quantity] forKey:@"quantity"];
	
	NSMutableArray *its = [[table items] mutableCopy];
	[its replaceObjectAtIndex:index withObject:[dict copy]];
	[table setItems:[its copy]];
	
	// refresh
	item = [[table items] objectAtIndex:index];
	[table save];
	
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
		return 2;
	}
	if (section == 1) {
		return 0;
	}
	if (section == 2) {
		return 1;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static __unused NSString *CellIdentifier = @"detail";
    UITableViewCell *cell;
	
	if (indexPath.section == 0) {
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
		
		Item *it = [item objectForKey:@"item"];
		
		if (indexPath.row == 0) {
			[[cell textLabel] setText:@"Base Price"];
			[[cell detailTextLabel] setText:[NSString stringWithFormat:@"£%.2f", [it.price floatValue]]];
		} else {
			[[cell textLabel] setText:@"Total Price"];
			[[cell detailTextLabel] setText:[NSString stringWithFormat:@"£%.2f", [it.price floatValue] * (float)quantity]];
		}
	} else if (indexPath.section == 2) {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 2) {
		TextareaCell *cell = (TextareaCell *)[tableView cellForRowAtIndexPath:indexPath];
		[[cell textField] becomeFirstResponder];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        return 100.f;
    }
    
    return 44.f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 2) {
		return @"Item-specific notes";
	}
	
	return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	if (section == 1) {
		if (!quantityStepper) {
			quantityStepper = [[UIStepper alloc] init];
			[quantityStepper setMinimumValue:1.f];
			[quantityStepper setStepValue:1.f];
			[quantityStepper setValue:[[item objectForKey:@"quantity"] floatValue]];
			[quantityStepper addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
			[quantityStepper setFrame:CGRectMake(self.tableView.frame.size.width - quantityStepper.frame.size.width - 20, 0, quantityStepper.frame.size.width, quantityStepper.frame.size.height)];
		}
		if (!quantityLabel) {
			quantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 29.f)];
			[quantityLabel setText:[NSString stringWithFormat:@"Quantity: %d", [[item objectForKey:@"quantity"] intValue]]];
		}
		
		UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 29.f)];
		[view addSubview:quantityLabel];
		[view addSubview:quantityStepper];
		
		return view;
	}
	
	return nil;
}

- (float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (section == 1) {
		return 29.f;
	}
	
	return 0.f;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"value"]) {
		quantity = (int)[(UIStepper *)object value];
		[quantityLabel setText:[NSString stringWithFormat:@"Quantity: %i", quantity]];
		
		[self saveItem];
	}
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
    
	[self saveItem];
	
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