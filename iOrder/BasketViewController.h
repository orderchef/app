//
//  BasketViewController.h
//  iOrder
//
//  Created by Matej Kramny on 02/11/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Table;

@interface BasketViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) Table *table;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end
