//
//  MainConfigurationTabBarController.h
//  Danci
//
//  Created by zhenghao on 12/3/13.
//  Copyright (c) 2013 mx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo+Server.h"

@interface MainConfigurationTabBarController : UITabBarController

// database
@property (nonatomic, strong) UIManagedDocument *danciDatabase;

// user
@property (nonatomic, strong) UserInfo *user;

@end
