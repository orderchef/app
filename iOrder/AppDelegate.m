//
//  AppDelegate.m
//  iOrder
//
//  Created by Matej Kramny on 27/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "AppDelegate.h"
#import "Storage.h"
#import "Connection.h"
#import "Bugsnag.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface AppDelegate () {
    MBProgressHUD *hud;
    UITapGestureRecognizer *tapToReconnect;
	UITapGestureRecognizer *tapToDisconnect;
}

@end

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Connection getConnection];
    [Storage getStorage];
    [self customizeAppearance];
    
    [Bugsnag startBugsnagWithApiKey:@"c987848f96714ef34560d05ef7e53b5d"];
    
    [[Connection getConnection] addObserver:self forKeyPath:@"isConnected" options:NSKeyValueObservingOptionNew context:nil];
    
    return YES;
}

- (void)lockApp {
    [[Connection getConnection] setShouldAttemptRecovery:NO];
    [[Connection getConnection] disconnect];
    
    [[LTHPasscodeViewController sharedUser] showLockscreenWithAnimation:NO];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self lockApp];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[Connection getConnection] setShouldAttemptRecovery:YES];
    [[Connection getConnection] connect];
}

- (void)customizeAppearance {
	[[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
	[[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.203f green:0.444f blue:0.768f alpha:1.f]];
	[[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	
	[[UITableView appearance] setSectionIndexBackgroundColor:[UIColor clearColor]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"isConnected"]) {
        bool connected = [[Connection getConnection] isConnected];
        
        if (!tapToReconnect) {
            tapToReconnect = [[UITapGestureRecognizer alloc] initWithTarget:[Connection getConnection] action:@selector(connect)];
			tapToDisconnect = [[UITapGestureRecognizer alloc] initWithTarget:[Connection getConnection] action:@selector(disconnect)];
        }
        
        if (connected) {
            [self showMessage:@"Connected" detail:nil hideAfter:0.5f showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:nil];
        } else {
			if ([[[Connection getConnection] socket] isConnecting]) {
				[self showMessage:@"Connecting..." detail:@"Tap to disconnect" hideAfter:0.f showAnimated:NO hideAnimated:NO hide:NO tapRecognizer:tapToDisconnect toView:nil];
			} else {
				[self showMessage:@"Disconnected!" detail:@"Tap to reconnect" hideAfter:0.f showAnimated:NO hideAnimated:NO hide:NO tapRecognizer:tapToReconnect toView:nil];
			}
        }
    }
}

- (void)showMessage:(NSString *)message detail:(NSString *)detail hideAfter:(NSTimeInterval)interval showAnimated:(BOOL)animated hideAnimated:(BOOL)hideAnimated hide:(BOOL)doesHide tapRecognizer:(UITapGestureRecognizer *)recognizer toView:(UIView *)view
{
    UIViewController *vc = [LTHPasscodeViewController sharedUser];
    bool isInLockscreen = vc.isViewLoaded && vc.view.window;
    
    if (hud) {
        [hud hide:NO];
        [hud removeFromSuperview];
        if (recognizer) {
            [hud removeGestureRecognizer:recognizer];
        }
    }
    
    if (isInLockscreen) {
        hud = [MBProgressHUD showHUDAddedTo:vc.view animated:animated];
        hud.yOffset = 40.f;
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			hud.yOffset = 0.f;
		}
    } else {
		UIViewController *controller = _window.rootViewController;
		while (controller.presentedViewController) {
			controller = controller.presentedViewController;
		}
		
		UIView *v = controller.view;
		if (view) {
			v = view;
		}
		
        hud = [MBProgressHUD showHUDAddedTo:v animated:animated];
        hud.yOffset = 100.f;
    }
    
    hud.mode = MBProgressHUDModeText;
    hud.margin = 10.f;
    
    hud.labelText = message;
    hud.detailsLabelText = detail;
    
    if (doesHide) {
        if (interval > 0.f) {
            [hud hide:hideAnimated afterDelay:interval];
        } else {
            [hud hide:hideAnimated];
        }
    }
    
    if (recognizer) {
        [hud addGestureRecognizer:recognizer];
    } else {
        hud.userInteractionEnabled = NO;
    }
}

@end
