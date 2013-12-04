//
//  BasketItemViewController.h
//  iOrder
//
//  Created by Matej Kramny on 04/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextareaCell.h"

@class Table;

@interface BasketItemViewController : UITableViewController <TextareaDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) NSDictionary *item;
@property (nonatomic, weak) Table *table;

@end
