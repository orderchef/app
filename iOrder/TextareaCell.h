//
//  TextFieldCell.h
//  iOrder
//
//  Created by Matej Kramny on 28/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TextareaDelegate <NSObject>

- (void)textFieldDidBeginEditing;
- (void)textFieldDidEndEditing;

@end

@interface TextareaCell : UITableViewCell <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textField;
@property id<TextareaDelegate> delegate;

@end
