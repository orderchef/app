//
//  CategoryViewController.h
//  iOrder
//
//  Created by Matej Kramny on 21/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ItemCategory;

@interface CategoryViewController : UITableViewController

@property (nonatomic, weak) ItemCategory *category;

@end
