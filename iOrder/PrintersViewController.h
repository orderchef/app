//
//  PrintersViewController.h
//  OrderChef
//
//  Created by Matej Kramny on 27/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ItemCategory;

@interface PrintersViewController : UITableViewController

@property (nonatomic, weak) ItemCategory *category;

@end
