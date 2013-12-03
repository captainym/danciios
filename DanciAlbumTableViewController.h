//
//  DanciAlbumTableViewController.h
//  Danci
//
//  Created by ShiYuming on 13-9-20.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface DanciAlbumTableViewController : CoreDataTableViewController


- (IBAction)onBtnSettings:(id)sender;


//单词数据库
@property (strong,nonatomic) UIManagedDocument *danciDatabase;

@property (strong, nonatomic) IBOutlet UITableView *tblAlbumIphone;
@property (strong, nonatomic) IBOutlet UITableView *tblAlbumIpad;
@property (strong, nonatomic) IBOutlet UIButton *btnSettings;

@end
