//
//  SettingsConfigurationViewController.h
//  Danci
//
//  Created by zhenghao on 12/4/13.
//  Copyright (c) 2013 mx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsConfigurationViewController : UIViewController

- (void) checkValue: (UITextField *)textField;


@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) UITextField *studyTime;

@property (strong, nonatomic) IBOutlet UITableView *tableViewSettings;

@end
