//
//  BasketViewController.h
//  iOrder
//
//  Created by Matej Kramny on 02/11/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextareaCell.h"

@class Table;
@class Order;

@interface BasketTableViewController : UITableViewController <TextareaDelegate, UIScrollViewDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) Table *table;
@property (nonatomic, weak) Order *activeOrder;

@end
