//
//  AppDelegate.h
//  iOrder
//
//  Created by Matej Kramny on 27/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)showMessage:(NSString *)message
             detail:(NSString *)detail
          hideAfter:(NSTimeInterval)interval
       showAnimated:(BOOL)animated
       hideAnimated:(BOOL)hideAnimated
               hide:(BOOL)doesHide
      tapRecognizer:(UITapGestureRecognizer *)recognizer;

@end
