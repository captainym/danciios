//
//  DanciWordViewController.h
//  Danci
//
//  Created by HuHao on 13-9-20.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "WordHttpClient.h"
#import "TQMultistageTableView.h"

#define cellTipimg @"CellTipImg"
#define cellTiptxt @"CellTipTxt"
#define cellTipsentence @"CellTipSentence"
#define HEIGHT_TIP_TXT 70
#define HEIGHT_SENTENCE 40
#define HEIGHT_TQ_ROW 60
#define HEIGHT_TQ_CELL 0
//图片的tableView需要150的宽度。ipad下可以考虑更大
#define HEIGHT_IMG_ROW 100.0
#define WORD_FAYIN @"fayin"
#define WORD_COMMENT @"comment"
#define WORD_FAYIN_MP3URL @"fayinMp3Url"
#define WORD_TIP_TXT @"tipTxt" //若有 则取自本地
#define WORD_GERN @"wordGern" //若有 取自本地
#define WORD_TIP_IMGS @"tipImgs"
#define WORD_TIP_TXTS @"tipTxts"
#define WORD_TIP_SENTENCES @"tipSentences"

@interface DanciWordViewController : UIViewController{
    UIButton *_btnCover;
}

//用户帐户信息
@property (nonatomic, strong) NSString *userMid;

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
//单词的中文释义
@property (nonatomic, strong) NSString *comment;
//单词词根词缀信息
@property (nonatomic, strong) NSString *wordGern;
//单词的助记图片
@property (nonatomic, strong) NSString *tipImgFilepath;
//单词的文字助记
@property (nonatomic, strong) NSString *tipTxt;
//单词的图片助记: [{tipImgId tipImgUrl adoptNum createTime}]
@property (nonatomic, strong) NSArray *tipImgs;
//单词的文字助记：[{tipTxtid tipTxt adoptNum createTime}]
@property (nonatomic, strong) NSMutableArray *tipTxts;
//单词的例句: [{例句 中文意思、Mp3}]
@property (nonatomic, strong) NSMutableArray *tipSentences;
//播放器
@property (nonatomic,strong) AVAudioPlayer *player;
//frame
@property (nonatomic) CGRect svNormFrame;
@property (nonatomic) CGRect svExpFrame;
//other
@property (nonatomic,strong) UIFont *fontDetail;

//other tool Instance
@property (nonatomic,strong) WordHttpClient *wordClient;

//iphone的tip控件
@property (nonatomic,strong) TQMultistageTableView *tblMultipsIphone;

#pragma - mark 控件
//iphone控件
@property (weak, nonatomic) IBOutlet UIScrollView *svMeaningStem;
//@property (weak, nonatomic) IBOutlet UILabel *lblMeaningStemIphone;
@property (weak, nonatomic) IBOutlet UIButton *btnTipImgIphone;
@property (weak, nonatomic) IBOutlet UITableView *tblTipimgsIphone;
@property (weak, nonatomic) IBOutlet UIView *vtip;


@end
