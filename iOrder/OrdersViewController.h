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

@interface OrdersViewController : UITableViewController

@property (nonatomic, weak) Table *table;
@property (nonatomic, weak) Order *activeOrder;

@end
