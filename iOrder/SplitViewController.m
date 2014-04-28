//
//  SplitViewController.m
//  OrderChef
//
//  Created by Matej Kramny on 17/04/2014.
//  Copyright (c) 2014 Matej Kramny. All rights reserved.
//

#import "SplitViewController.h"

@interface SplitViewController ()

@end

@implementation SplitViewController

- (void)viewDidLoad
{
	[self setDelegate:self];
	
    [super viewDidLoad];
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
	return NO;
}

@end
