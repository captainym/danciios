//
//  DanciAlbumTableViewController.h
//  Danci
//
//  Created by HuHao on 13-9-20.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DanciAlbumTableViewController : UITableViewController

//albums
//album的内容是：albumid albumName pointword words
@property (nonatomic, strong) NSArray *albums;

@end
