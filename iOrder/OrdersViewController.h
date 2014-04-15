//
//  OrdersViewController.h
//  OrderChef
//
//  Created by Matej Kramny on 27/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Table;
@class Order;
@class OrderGroup;

@interface OrdersViewController : UITableViewController <UIActionSheetDelegate>

@property (nonatomic, strong) Table *table;
@property (nonatomic, weak) OrderGroup *group;

@end
