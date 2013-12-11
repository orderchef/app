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

@interface BasketTableViewController : UITableViewController <TextareaDelegate, UIScrollViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) Table *table;

@end
