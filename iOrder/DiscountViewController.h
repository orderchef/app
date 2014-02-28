//
//  DiscountViewController.h
//  OrderChef
//
//  Created by Matej Kramny on 26/02/2014.
//  Copyright (c) 2014 Matej Kramny. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Discount;

@interface DiscountViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, weak) Discount *discount;

@end
