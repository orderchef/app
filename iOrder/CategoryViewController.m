//
//  CategoryViewController.m
//  iOrder
//
//  Created by Matej Kramny on 21/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "CategoryViewController.h"
#import "TextFieldCell.h"
#import "ItemCategory.h"
#import "AppDelegate.h"

@interface CategoryViewController () {
	BOOL save;
	
	// Hard-coded. should be programmatic rather sooner than later
	UISwitch *drink;
	UILabel *drinkLabel;
	UIView *drinkFooter;
	
	UISwitch *hotFood;
	UILabel *hotFoodLabel;
	UIView *hotFoodFooter;
	
	UISwitch *sushi;
	UILabel *sushiLabel;
	UIView *sushiFooter;
}

@end

@implementation CategoryViewController

@synthesize category;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	save = true;
	
	[self.navigationItem setTitle:category.name];
	if (category.name.length == 0) {
        [self.navigationItem setTitle:@"New Category"];
    }
	
	if (category._id.length > 0) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"\uf014 " style:UIBarButtonItemStylePlain target:self action:@selector(deleteCategory:)];
		[self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{
																		 NSFontAttributeName: [UIFont fontWithName:@"FontAwesome" size:24]
																		 } forState:UIControlStateNormal];
	}

}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	if (save && category.name.length > 0) {
        [category save];
    }
}

- (void)titleChanged:(id)sender {
	TextFieldCell *cell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	[category setName:cell.textField.text];
    
    if (category.name.length == 0 && category._id.length > 0) {
        [self.navigationItem setTitle:@"Enter a Name"];
        [self.navigationItem setHidesBackButton:YES animated:NO];
    } else {
		if (category.name.length == 0 && category._id.length == 0) {
			[self.navigationItem setTitle:@"New Category"];
		} else {
			[self.navigationItem setTitle:category.name];
			
		}
		
        [self.navigationItem setHidesBackButton:NO animated:YES];
    }
}

- (void)drinkToggle:(id)sender {
	category.drink = [drink isOn];
}

- (void)hotFoodToggle:(id)sender {
	category.hotFood = hotFood.isOn;
}

- (void)sushiToggle:(id)sender {
	category.sushi = sushi.isOn;
}

- (void)deleteCategory:(id)sender {
	// Delete
	save = false;
	[category deleteCategory];
	
	[(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:[category.name stringByAppendingString:@" Deleted"] detail:Nil hideAfter:0.5 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:self.parentViewController.view];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
		return 1;
	}
	
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"text";
    
	if (indexPath.section == 0) {
		TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
		if (!cell) {
			cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		}
		
		cell.textField.placeholder = @"Category Name (required)";
		cell.textField.text = category.name;
		[cell.textField addTarget:self action:@selector(titleChanged:) forControlEvents:UIControlEventEditingChanged];
		
		return cell;
	}
	
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		TextFieldCell *cell = (TextFieldCell *)[tableView cellForRowAtIndexPath:indexPath];
		[cell.textField becomeFirstResponder];
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	if (section == 1) {
		if (!drink) {
			drink = [[UISwitch alloc] init];
			[drink addTarget:self action:@selector(drinkToggle:) forControlEvents:UIControlEventValueChanged];
			[drink setFrame:CGRectMake(self.tableView.frame.size.width - drink.frame.size.width - 20, 0, drink.frame.size.width, drink.frame.size.height)];
		}
		if (!drinkLabel) {
			drinkLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 29.f)];
			[drinkLabel setText:@"Drink"];
		}
		
		if (!drinkFooter) {
			drinkFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 29.f)];
			[drinkFooter addSubview:drink];
			[drinkFooter addSubview:drinkLabel];
		}
		
		[drink setOn:category.drink];
		
		return drinkFooter;
	} else if (section == 2) {
		if (!hotFood) {
			hotFood = [[UISwitch alloc] init];
			[hotFood addTarget:self action:@selector(hotFoodToggle:) forControlEvents:UIControlEventValueChanged];
			[hotFood setFrame:CGRectMake(self.tableView.frame.size.width - hotFood.frame.size.width - 20, 0, hotFood.frame.size.width, hotFood.frame.size.height)];
		}
		if (!hotFoodLabel) {
			hotFoodLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 29.f)];
			[hotFoodLabel setText:@"Hot Food"];
		}
		
		if (!hotFoodFooter) {
			hotFoodFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 29.f)];
			[hotFoodFooter addSubview:hotFood];
			[hotFoodFooter addSubview:hotFoodLabel];
		}
		
		[hotFood setOn:category.hotFood];
		
		return hotFoodFooter;
	}  else if (section == 3) {
		if (!sushi) {
			sushi = [[UISwitch alloc] init];
			[sushi addTarget:self action:@selector(sushiToggle:) forControlEvents:UIControlEventValueChanged];
			[sushi setFrame:CGRectMake(self.tableView.frame.size.width - sushi.frame.size.width - 20, 0, sushi.frame.size.width, sushi.frame.size.height)];
		}
		if (!sushiLabel) {
			sushiLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 29.f)];
			[sushiLabel setText:@"Sushi"];
		}
		
		if (!sushiFooter) {
			sushiFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 29.f)];
			[sushiFooter addSubview:sushi];
			[sushiFooter addSubview:sushiLabel];
		}
		
		[sushi setOn:category.sushi];
		
		return sushiFooter;
	}
	
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (section >= 1 && section <= 3) {
		return 29.f;
	}
	
	return 0.f;
}

@end
