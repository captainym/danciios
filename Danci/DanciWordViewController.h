//
//  DanciWordViewController.h
//  Danci
//
//  Created by HuHao on 13-9-20.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DanciWordViewController : UITableViewController

//album info
@property (nonatomic, strong) NSString *albumName;
//单词本中用户的学习断点。 由album指定 通常是用户第一个没有学习过的单词（未反馈>认识、不认识）的下标
@property (nonatomic) int wordPoint;
// words of the album
@property (nonatomic, strong) NSArray *words;
// 正在学习的单词下标和正在复习的单词下标
@property int pointStudy;
@property int pointCurReview;


//助记图片的tableview
@property (weak, nonatomic) IBOutlet UITableView *tblTipImgs;
//助记文字的tableview
@property (weak, nonatomic) IBOutlet UITableView *tblTipTxts;
//助记 例句
@property (weak, nonatomic) IBOutlet UITableView *tblTipSentens;


@end
