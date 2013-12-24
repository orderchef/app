//
//  MenuViewController.h
//  iOrder
//
//  Created by Matej Kramny on 28/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Table;
@class Order;

@interface MenuViewController : UITableViewController <UISearchBarDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) Table *table;
@property (nonatomic , weak) Order *activeOrder;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
