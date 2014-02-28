//
//  BasketViewController.h
//  iOrder
//
//  Created by Matej Kramny on 02/11/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextareaCell.h"
#import <CoreLocation/CoreLocation.h>
#import "MenuViewController.h"

@class Table;
@class Order;

@interface OrderViewController : UITableViewController <TextareaDelegate, UIActionSheetDelegate, CLLocationManagerDelegate, MenuControlDelegate, UITextFieldDelegate>

@property (nonatomic, weak) Table *table;
@property (nonatomic, weak) Order *order;

@end
