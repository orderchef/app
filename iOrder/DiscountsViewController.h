//
//  DiscountsViewController.h
//  OrderChef
//
//  Created by Matej Kramny on 07/02/2014.
//  Copyright (c) 2014 Matej Kramny. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OrderGroup;

@interface DiscountsViewController : UITableViewController

@property (nonatomic, weak) OrderGroup *group;

@end
