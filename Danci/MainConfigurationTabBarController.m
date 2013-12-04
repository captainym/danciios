//
//  MainConfigurationTabBarController.m
//  Danci
//
//  Created by zhenghao on 12/3/13.
//  Copyright (c) 2013 mx. All rights reserved.
//

#import "MainConfigurationTabBarController.h"
#import "UserConfigurationViewController.h"
#import "AchievementConfigurationViewController.h"


@interface MainConfigurationTabBarController () <UITabBarControllerDelegate>

@end

@implementation MainConfigurationTabBarController

@synthesize danciDatabase = _danciDatabase;
@synthesize user = _user;

- (UserInfo *) user
{
    if(_user == nil){
        _user = [UserInfo getUser:self.danciDatabase.managedObjectContext];
    }
    return _user;
}

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
    
    [self setDelegate:self]; // for UITabBarControllerDelegate

    self.title = @"用户信息";
    
    // 传递danciDatabase到UserConfigurationViewController
    for (UIViewController * viewController in self.viewControllers) {
        if ([viewController isKindOfClass:[UserConfigurationViewController class]]) {
            UserConfigurationViewController *userConfigurationViewController = (UserConfigurationViewController *)viewController;
            [userConfigurationViewController setDanciDatabase:self.danciDatabase];
            [userConfigurationViewController setUser:self.user];
        }
        else if ([viewController isKindOfClass:[AchievementConfigurationViewController class]]) {
            AchievementConfigurationViewController *achievementConfigurationViewController = (AchievementConfigurationViewController *)viewController;
            [achievementConfigurationViewController setDanciDatabase:self.danciDatabase];
            [achievementConfigurationViewController setUser:self.user];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    // 更新标题
    self.title = viewController.title;
//    if ([viewController isKindOfClass:[UserConfigurationViewController class]]) {
//        UserConfigurationViewController *userConfigurationViewController = (UserConfigurationViewController *)viewController;
//        [userConfigurationViewController setDanciDatabase:self.danciDatabase];
//    }
}

@end
