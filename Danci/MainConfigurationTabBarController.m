//
//  MainConfigurationTabBarController.m
//  Danci
//
//  Created by zhenghao on 12/3/13.
//  Copyright (c) 2013 mx. All rights reserved.
//

#import "MainConfigurationTabBarController.h"
#import "UserConfigurationViewController.h"


@interface MainConfigurationTabBarController () <UITabBarControllerDelegate>

@end

@implementation MainConfigurationTabBarController

@synthesize danciDatabase;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"设置";
    [self setDelegate:self]; // for UITabBarControllerDelegate
    
    // 传递danciDatabase到UserConfigurationViewController
    for (UIViewController * viewController in self.viewControllers) {
        if ([viewController isKindOfClass:[UserConfigurationViewController class]]) {
            UserConfigurationViewController *userConfigurationViewController = (UserConfigurationViewController *)viewController;
            [userConfigurationViewController setDanciDatabase:self.danciDatabase];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
////    if ([viewController isKindOfClass:[UserConfigurationViewController class]]) {
////        UserConfigurationViewController *userConfigurationViewController = (UserConfigurationViewController *)viewController;
////        [userConfigurationViewController setDanciDatabase:self.danciDatabase];
////    }
//}

@end
