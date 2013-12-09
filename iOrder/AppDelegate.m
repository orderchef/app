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

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Connection getConnection];
    [Storage getStorage];
    [self customizeAppearance];
    
    [Bugsnag startBugsnagWithApiKey:@"c987848f96714ef34560d05ef7e53b5d"];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[Connection getConnection] disconnect];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[Connection getConnection] connect];
}

- (void)customizeAppearance {
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	[[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
	[[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.203f green:0.444f blue:0.768f alpha:1.f]];
	//[[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.398f green:0.798f blue:0.802f alpha:1.f]];
	[[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

@end
