//
//  DanciWordViewController.h
//  Danci
//
//  Created by HuHao on 13-9-20.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define cellTipimg @"CellTipImg"
#define cellTiptxt @"CellTipTxt"
#define cellTipsentence @"CellTipSentence"

@interface DanciWordViewController : UIViewController

//指示当前页面是新学习还是复习；
@property BOOL isNewStudy;
//指示当前的单词是学习还是复习。如果是复习单词，这个值将一直是TRUE，否则按照马上复习的逻辑来设置，该值指示界面是否切换到复习界面：反馈按钮的title及其逻辑、tips的折叠与否、助记图片加载。只要是学习过的单词，这个值都是TRUE。
@property BOOL isReview;

//album info
@property (nonatomic, strong) NSString *albumName;
//单词本中用户的学习断点。 由album指定 通常是用户第一个没有学习过的单词（未反馈>认识、不认识）的下标
@property (nonatomic) int wordPoint;
// 开始新学习或复习的单词表
@property (nonatomic, strong) NSArray *words;
// 需要马上复习的单词列表
@property (nonatomic, strong) NSArray *wordsReviewNow;
// 需要立即复习的单词下标
@property int pointReviewNow;
//单词 - 当前正在学习或复习的单词
@property (nonatomic, strong) NSString *word;
//单词的发音 以便和单词一起作为navigation的title
@property (nonatomic, strong) NSString *fayin;
@property (nonatomic, strong) NSString *fayinMp3Url;
//单词的助记图片
@property (nonatomic, strong) NSString *tipImgFilepath;
//单词的中文释义
@property (nonatomic, strong) NSString *comment;
//单词词根词缀信息
@property (nonatomic, strong) NSString *wordGern;
//单词的图片助记: [{tipImgId tipImgUrl adoptNum createTime}]
@property (nonatomic, strong) NSArray *tipImgs;
//单词的文字助记：[{tipTxtid tipTxt adoptNum createTime}]
@property (nonatomic, strong) NSMutableArray *tipTxts;
//单词的例句: [{例句 中文意思、Mp3}]
@property (nonatomic, strong) NSMutableArray *tipSentences;
//播放器
@property (nonatomic,strong) AVAudioPlayer *player;

//控件
@property (weak, nonatomic) IBOutlet UILabel *lblMeaning;
@property (weak, nonatomic) IBOutlet UILabel *lblStem;
@property (weak, nonatomic) IBOutlet UIImageView *imgTipimg;

@property (weak, nonatomic) IBOutlet UITableView *tblTipimgs;
@property (weak, nonatomic) IBOutlet UITableView *tblTipsentense;
@property (weak, nonatomic) IBOutlet UITableView *tblTiptxt;


 
@end
