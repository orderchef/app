//
//  AppDelegate.h
//  iOrder
//
//  Created by Matej Kramny on 27/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMasterIP @"127.0.0.1"
#define kMasterPort 8000

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)showMessage:(NSString *)message
             detail:(NSString *)detail
          hideAfter:(NSTimeInterval)interval
       showAnimated:(BOOL)animated
       hideAnimated:(BOOL)hideAnimated
               hide:(BOOL)doesHide
      tapRecognizer:(UITapGestureRecognizer *)recognizer
			 toView:(UIView *)view;

- (void)lockApp;

@end
