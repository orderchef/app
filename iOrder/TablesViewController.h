//
//  TableViewController.h
//  iOrder
//
//  Created by Matej Kramny on 27/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TablesViewController : UITableViewController <UIAlertViewDelegate>

@property (assign) BOOL manageEnabled;

- (void)reloadData;

@end
