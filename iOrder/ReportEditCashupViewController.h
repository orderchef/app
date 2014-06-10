//
//  ReportEditCashupViewController.h
//  OrderChef
//
//  Created by Matej Kramny on 22/05/2014.
//  Copyright (c) 2014 Matej Kramny. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportEditCashupViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) NSMutableDictionary *cashReport;
@property (assign) bool justEat;

@end
