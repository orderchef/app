//
//  DiscountTablesViewController.h
//  OrderChef
//
//  Created by Matej Kramny on 28/02/2014.
//  Copyright (c) 2014 Matej Kramny. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Discount;

@interface DiscountTablesViewController : UITableViewController

// List of ObjectIds borrowed from a Discount object..
@property (nonatomic, weak) Discount *discount;

@end
