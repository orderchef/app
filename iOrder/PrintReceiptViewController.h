//
//  PrintReceiptViewController.h
//  OrderChef
//
//  Created by Matej Kramny on 10/05/2014.
//  Copyright (c) 2014 Matej Kramny. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OrderGroup;
@class OrdersViewController;

@interface PrintReceiptViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) OrderGroup *group;
@property (weak, nonatomic) OrdersViewController *parentView;
@property (weak, nonatomic) UIPopoverController *popover;

- (IBAction)printAndClear:(UIBarButtonItem *)sender;
- (IBAction)print:(UIBarButtonItem *)sender;

@end
