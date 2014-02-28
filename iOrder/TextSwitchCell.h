//
//  TextSwitchCell.h
//  OrderChef
//
//  Created by Matej Kramny on 28/02/2014.
//  Copyright (c) 2014 Matej Kramny. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextSwitchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UISwitch *checkbox;

@end
