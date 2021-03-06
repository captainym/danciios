//
//  AchievementConfigurationViewController.h
//  Danci
//
//  Created by zhenghao on 12/4/13.
//  Copyright (c) 2013 mx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo+Server.h"

@interface AchievementConfigurationViewController : UIViewController

//database
@property (nonatomic, strong) UIManagedDocument *danciDatabase;

// user
@property (nonatomic, strong) UserInfo *user;

@property (strong, nonatomic) IBOutlet UITableView *tableViewUserAchievement;

@end
