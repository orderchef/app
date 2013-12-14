//
//  CategoryViewController.h
//  iOrder
//
//  Created by Matej Kramny on 28/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Item;

@interface ItemController : UITableViewController <UIAlertViewDelegate>

@property (nonatomic, weak) Item *item;

@end
