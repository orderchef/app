//
//  MenuViewController.h
//  iOrder
//
//  Created by Matej Kramny on 28/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Table;

@interface MenuViewController : UITableViewController <UISearchBarDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) Table *table;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
