//
//  BasketItemViewController.m
//  iOrder
//
//  Created by Matej Kramny on 04/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "OrderItemViewController.h"
#import "Item.h"
#import "Table.h"
#import "AppDelegate.h"
#import "OrderGroup.h"
#import "Order.h"

@interface OrderItemViewController () {
    UITapGestureRecognizer *dismissKeyboardGesture;
	
	UIStepper *quantityStepper;
	UILabel *quantityLabel;
	
	int quantity;
	NSString *notes;
}

@end

@implementation OrderItemViewController

@synthesize item;
@synthesize table;
@synthesize order;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	Item *it = [item objectForKey:@"item"];
	[self.navigationItem setTitle:it.name];
	
	quantity = [[item objectForKey:@"quantity"] intValue];
	notes = [item objectForKey:@"notes"];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"\uf014 " style:UIBarButtonItemStylePlain target:self action:@selector(deleteItemFromTable:)];
	[self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{
																	 NSFontAttributeName: [UIFont fontWithName:@"FontAwesome" size:24]
																	 } forState:UIControlStateNormal];
    
}

- (void)saveItem {
	TextareaCell *cell = (TextareaCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
	int index = (int)[[order items] indexOfObject:item];
	
	NSMutableDictionary *dict = [item mutableCopy];
	[dict setObject:[cell.textField text] forKey:@"notes"];
	[dict setObject:[NSNumber numberWithInteger:quantity] forKey:@"quantity"];
	
	NSMutableArray *its = [[order items] mutableCopy];
	[its replaceObjectAtIndex:index withObject:[dict copy]];
	[order setItems:[its copy]];
	
	// refresh
	item = [[order items] objectAtIndex:index];
	[order save];
	
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
		return 3;
	}
	if (section == 1) {
		return 0;
	}
	if (section == 2) {
		return 1;
	}
	if (section == 3) {
		return [[item objectForKey:@"discounts"] count];
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
		
		float price = [[item objectForKey:@"price"] floatValue];
		
		if (indexPath.row == 0) {
			[[cell textLabel] setText:@"Price Original"];
			[[cell detailTextLabel] setText:[NSString stringWithFormat:@"£%.2f", [it.price floatValue]]];
		} else if (indexPath.row == 1) {
			[[cell textLabel] setText:@"Price After Discounts"];
			[[cell detailTextLabel] setText:[NSString stringWithFormat:@"£%.2f", price]];
		} else if (indexPath.row == 2) {
			[[cell textLabel] setText:@"Total for Order"];
			[[cell detailTextLabel] setText:[NSString stringWithFormat:@"£%.2f", price * (float)quantity]];
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
	} else if (indexPath.section == 3) {
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
		
		NSDictionary *discount = [[item objectForKey:@"discounts"] objectAtIndex:indexPath.row];
		cell.textLabel.text = [discount objectForKey:@"name"];
		cell.detailTextLabel.text = [NSString stringWithFormat:@"£%.2f", [[discount objectForKey:@"value"] floatValue]];
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 2) {
		TextareaCell *cell = (TextareaCell *)[tableView cellForRowAtIndexPath:indexPath];
		[[cell textField] becomeFirstResponder];
	}
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        return 100.f;
    }
    
    return 44.f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 2) {
		return @"Item-specific notes";
	}
	if (section == 3 && [[item objectForKey:@"discounts"] count] > 0) {
		return @"Discounts";
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
			quantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 120, 29.f)];
			[quantityLabel setText:[NSString stringWithFormat:@"Quantity: %d", [[item objectForKey:@"quantity"] intValue]]];
		}
		
		UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 29.f)];
		[view addSubview:quantityLabel];
		[view addSubview:quantityStepper];
		
		return view;
	}
	
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (section == 1) {
		return 29.f;
	}
	
	return 0.f;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"value"]) {
		quantity = (int)[(UIStepper *)object value];
		[quantityLabel setText:[NSString stringWithFormat:@"Quantity: %i", quantity]];
		
		Item *it = [item objectForKey:@"item"];
		
		AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
		[delegate showMessage:[NSString stringWithFormat:@"%dx %@", quantity, it.name] detail:nil hideAfter:0.5 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:self.navigationController.view];
		
		[self saveItem];
	}
}

- (void)deleteItemFromTable:(id)sender {
	Item *it = [item objectForKey:@"item"];
	[order removeItem:it];
	
	[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:it.name detail:@"Removed from Basket" hideAfter:0.5 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:self.parentViewController.view];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TextfieldDelegate methods

- (void)dismissKeyboard:(id)sender {
    TextareaCell *cell = (TextareaCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    [[cell textField] resignFirstResponder];
}

- (void)textFieldDidBeginEditing {
    dismissKeyboardGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    dismissKeyboardGesture.cancelsTouchesInView = YES;
    
    [self.tableView addGestureRecognizer:dismissKeyboardGesture];
}

- (void)textFieldDidEndEditing {
	[self saveItem];
	
    @try {
        [self.tableView removeGestureRecognizer:dismissKeyboardGesture];
    }
    @catch (NSException *exception) {}
    @finally {
        dismissKeyboardGesture = nil;
    }
}

@end
