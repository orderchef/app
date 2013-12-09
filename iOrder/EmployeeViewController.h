//
//  EmployeeViewController.h
//  iOrder
//
//  Created by Matej Kramny on 09/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Staff;

@interface EmployeeViewController : UITableViewController <UIScrollViewDelegate>

@property (nonatomic, weak) Staff *employee;

@end
