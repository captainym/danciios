//
//  DanciWordViewController.h
//  Danci
//
//  Created by ShiYuming on 13-9-20.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "WordHttpClient.h"
#import "TQMultistageTableView.h"
#import "Album+Server.h"
#import "Word+Server.h"

#define CELL_ID_TIPIMG @"CellTipImg"
#define CELL_ID_TIPSENTENCE @"CellTipSentence"

//图片的tableView需要150的宽度。ipad下可以考虑更大
#define HEIGHT_IMG_ROW 100.0
#define HEIGHT_SENTENCE_ROW 60

#define SEGUE_EDIT @"sgEditTipTxt"
#define KEY_TIPS_SENTENCE_ENGLISH @"sentence"
#define KEY_TIPS_SENTENCE_CHINESE @"meaning"
#define KEY_TIPS_SENTENCE_MP3 @"mp3"
#define DEFAULT_REQUEST_COUNT_IMG 20

@interface DanciWordViewController : UIViewController{
    UIButton *_btnCover;
}

//用户帐户信息
@property (nonatomic, strong) NSString *userMid;

//指示当前页面是新学习还是复习；
@property BOOL isNewStudy;

//database
@property (nonatomic, strong) UIManagedDocument *danciDatabase;
//album info
@property (nonatomic, strong) Album *album;

//单词本中用户的学习断点。 由album指定 通常是用户第一个没有学习过的单词（未反馈>认识、不认识）的下标
//@property (nonatomic) int wordPoint;
// 开始新学习或复习的单词表
@property (nonatomic, strong) NSArray *words;
// 需要马上复习的单词列表
@property (nonatomic, strong) NSArray *wordsReviewNow;
// 需要立即复习的单词下标
@property int pointReviewNow;
//单词 - 当前正在学习或复习的单词
@property (nonatomic, strong) Word *word;
//单词 － 当前背诵的单词 触发单词的更新
@property (nonatomic, strong) NSString *wordTerm;
//在懒加载中动态生成
@property (nonatomic, strong) NSString *fayinMp3Url;
//单词的助记图片 在懒加载中自动计算给出
@property (nonatomic, strong) NSString *tipImgFilepath;
//单词的图片助记，动态地从server上取得
@property (nonatomic, strong) NSMutableArray *tipImgs;
//单词的例句，动态地从server上取得
@property (nonatomic, strong) NSArray *tipSentences;
//播放器
@property (nonatomic,strong) AVAudioPlayer *player;
//frame
//@property (nonatomic) CGRect svNormFrame;
//@property (nonatomic) CGRect svExpFrame;
//other
@property (nonatomic,strong) UIFont *fontDetail;

#pragma - mark 控件
//iphone控件
@property (weak, nonatomic) IBOutlet UILabel *lblMeaning;
@property (weak, nonatomic) IBOutlet UIButton *btnTipImgIphone;
@property (weak, nonatomic) IBOutlet UITableView *tblTipimgsIphone;
@property (weak, nonatomic) IBOutlet UITableView *tblTipSentence;
@property (weak, nonatomic) IBOutlet UIView *vtip;
@property (weak, nonatomic) IBOutlet UILabel *lbltips;


@end
