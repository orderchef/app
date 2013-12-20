//
//  TextFieldCell.m
//  iOrder
//
//  Created by Matej Kramny on 28/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "TextareaCell.h"

@implementation TextareaCell

@synthesize textField;
@synthesize delegate;

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (delegate && [delegate respondsToSelector:@selector(textFieldDidBeginEditing)]) {
        [delegate textFieldDidBeginEditing];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (delegate && [delegate respondsToSelector:@selector(textFieldDidEndEditing)]) {
        [delegate textFieldDidEndEditing];
    }
}

@end
