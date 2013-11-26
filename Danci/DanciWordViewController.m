//
//  DanciWordViewController.m
//  Danci
//
//  Created by ShiYuming on 13-9-20.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import "DanciWordViewController.h"
#import "PPImageScrollingTableViewCell.h"
#import "UIPopoverListView.h"
#import "PPCollectionViewCell.h"

#import "DanciEditTipTxtViewController.h"


@interface DanciWordViewController () <PPImageScrollingTableViewCellDelegate, UITableViewDataSource,UITableViewDelegate,AVAudioPlayerDelegate,TQTableViewDataSource, TQTableViewDelegate , UIPopoverListViewDelegate, DanciEditTipTxtDelegate>
@property (nonatomic, strong) UILabel *lblHeaderTip;

@end

@implementation DanciWordViewController

//properties synthesize
@synthesize isNewStudy = _isNewStudy;
@synthesize isReview = _isReview;

@synthesize userMid = _userMid;

@synthesize albumName = _albumName;
@synthesize wordPoint = _wordPoint;
@synthesize words = _words;
@synthesize wordsReviewNow = _wordsReviewNow;
@synthesize pointReviewNow = _pointCurReview;
@synthesize word = _word;
@synthesize wordGern = _wordGern;
@synthesize tipImgs = _tipImgs;
@synthesize tipTxts = _tipTxts;
@synthesize tipSentences = _tipSentences;
@synthesize player = _player;
@synthesize svExpFrame = _svExpFrame;
@synthesize svNormFrame = _svNormFrame;
@synthesize fontDetail = _fontDetail;
@synthesize wordClient = _wordClient;

#pragma mark- properties

- (void) setIsReview:(BOOL)isReview
{
    _isReview = isReview;
}
- (BOOL) isReview
{
    //如果是复习单词，这个值将一直是TRUE
    if (!self.isNewStudy) {
        return TRUE;
    }
    return _isReview;
}

//lazy load
- (NSArray *) words
{
    if(_words == nil){
        _words = [[NSArray alloc] init];
    }
    return _words;
}

- (NSArray *) wordsReviewNow
{
    if(_wordsReviewNow == nil) _wordsReviewNow = [[NSArray alloc] init];
    return _wordsReviewNow;
}

- (NSArray *) tipImgs
{
    if(_tipImgs == nil){
        _tipImgs = [[NSArray alloc] init];
    }
    return _tipImgs;
}

- (NSMutableArray *) tipTxts
{
    if(_tipTxts == nil) _tipTxts = [[NSMutableArray alloc] init];
    return _tipTxts;
}

- (NSMutableArray *) tipSentences
{
    if(_tipSentences == nil) _tipSentences = [[NSMutableArray alloc] init];
    return _tipSentences;
}

- (void)setWordPoint:(int)wordPoint
{
    _wordPoint = wordPoint;
}

- (NSString *) word
{
    if(![_word isEqualToString: [self.words objectAtIndex:self.wordPoint]]){
        NSLog(@"word not equal. load again. _word[%@] new word[%@]", _word,[self.words objectAtIndex:self.wordPoint]);
        _word = [self.words objectAtIndex:self.wordPoint];
        if ([self getWordInfo] != 0) {
            NSLog(@"get wordinfo failed. word would be nil. word[%@]", self.word);
            return nil;
        }
    }
    return _word;
}

-(CGRect) svExpFrame
{
    if(_svExpFrame.origin.x < 1){
        _svExpFrame = CGRectMake(3.0, 110, 314, 320);
        NSLog(@"after _svExpFrame. x[%f] y[%f] height[%f] width[%f]",_svExpFrame.origin.x,_svExpFrame.origin.y,_svExpFrame.size.height,_svExpFrame.size.width);
    }
    return _svExpFrame;
}
-(CGRect) svNormFrame
{
    if(_svNormFrame.origin.x < 1){
        _svNormFrame = CGRectMake(3.0, 218, 314, 230);
        NSLog(@"after _svNormFrame. x[%f] y[%f] height[%f] width[%f]",_svNormFrame.origin.x,_svNormFrame.origin.y,_svNormFrame.size.height,_svNormFrame.size.width);
    }
    return _svNormFrame;
}

-(NSString *) userMid
{
    if([_userMid length] < 1 ){
        //core data 取值
//        _userMid = @"18601920512";
    }
    if([_userMid length] < 1){
        return nil;
    }
    return _userMid;
}

-(UIFont *) fontDetail
{
    if(!_fontDetail){
        _fontDetail = [UIFont fontWithName:@"Verdana" size:11];
    }
    return _fontDetail;
}

-(WordHttpClient *) wordClient
{
    if(_wordClient == nil)
    {
        _wordClient = [[WordHttpClient alloc] init];
        NSLog(@"wordClient init OK!");
    }
    return _wordClient;
}

#pragma mark -  methods

//从coredata中取出当前word的各种信息： 发音 真人发音mp3 中文释义 词根词缀 例句 例句mp3地址 从网络获取tipImgs tipTxts 例句mp3
//成功返回0 失败返回－1或其他数字
- (int) getWordInfo
{
//    [self getWordInfo_bak];
//    return 0;
    
    NSDictionary *infoDict = [self.wordClient getWordInfo:self.word];
    if(infoDict == nil || [infoDict count] < 1)
    {
        NSLog(@"get word info Failed!");
        return -1;
    }
    if ([[infoDict objectForKey:@"status"] intValue] != 0) {
        NSLog(@"get word info Failed!");
        return -1;
    }
    
    infoDict = [infoDict objectForKey:@"data"];
    
    //填充wordinfo
    self.fayin = [infoDict objectForKey:WORD_FAYIN];
    self.comment = [infoDict objectForKey:WORD_COMMENT];
    self.fayinMp3Url = [infoDict objectForKey:WORD_FAYIN_MP3URL];
    self.tipTxt = [infoDict objectForKey:WORD_TIP_TXT];
    self.wordGern = [infoDict objectForKey:WORD_GERN];
    self.tipImgs = [infoDict objectForKey:WORD_TIP_IMGS];
    self.tipTxts = [infoDict objectForKey:WORD_TIP_TXTS];
    self.tipSentences = [infoDict objectForKey:WORD_TIP_SENTENCES];
    
    
    //先用假数据
//    NSDictionary *wordInfo = [self getWordInfoByCoredata:_word];
//    if(wordInfo != nil) {
//        self.fayin = [wordInfo valueForKey:WORD_FAYIN];
//        self.comment = [wordInfo valueForKey:WORD_COMMENT];
//        self.wordGern = [wordInfo valueForKey:WORD_GERN];
//    }
    self.fayin = @"[saɪˈkɒlədʒɪ]";
    self.comment = @"n.【心】心理学；心理特征；〈非正式〉【心】看穿别人心理的能力";
    self.wordGern = @"psy=sci，是一个偏旁部首，是“知道”的意思； cho是一个偏旁部首，是“心”的意思； lo是一个偏旁部首，是“说”的意思； gy是一个偏旁部首，是“学”的意思，logy合起来是“学说”的意思。 psy-cho-logy连起来就是“知道心的学说”。";

    //    self.fayinMp3Url = @"wordmp3/p/psychology.arm";
    self.fayinMp3Url = @"/Users/huhao/Developer/psychology.mp3";
    
    return 0;
}

- (void) getWordInfo_bak
{
    //先用假数据
    self.fayin = @"[saɪˈkɒlədʒɪ]";
    self.comment = @"n.【心】心理学；心理特征；〈非正式〉【心】看穿别人心理的能力";
//    self.fayinMp3Url = @"wordmp3/p/psychology.arm";
    self.fayinMp3Url = @"/Users/huhao/Developer/psychology.mp3";
    self.tipTxt = @"log=science,表示\"科学,学科\"。psychology n 心理学（paych 心理+o+log+y) ";
    self.wordGern = @"psy=sci，是一个偏旁部首，是“知道”的意思； cho是一个偏旁部首，是“心”的意思； lo是一个偏旁部首，是“说”的意思； gy是一个偏旁部首，是“学”的意思，logy合起来是“学说”的意思。 psy-cho-logy连起来就是“知道心的学说”。";

    self.tipImgs = @[
                     @{ @"name":@"psychology_md51.jpeg", @"url":@"http://ts2.mm.bing.net/th?id=H.4606907701657645&w=125&h=145&c=7&rs=1&pid=1.7"},
                     @{ @"name":@"name-sample_2.jpeg", @"url":@"http://ts1.mm.bing.net/th?id=H.4798712300766788&w=186&h=145&c=7&rs=1&pid=1.7"},
                     @{ @"name":@"name-sample_3.jpeg", @"url":@"http://ts2.mm.bing.net/th?id=H.5012038975817713&w=201&h=145&c=7&rs=1&pid=1.7"},
                     @{ @"name":@"name-sample_4.jpeg", @"url":@"http://ts1.mm.bing.net/th?id=H.4721716456259760&w=215&h=145&c=7&rs=1&pid=1.7"},
                     @{ @"name":@"name-sample_5.jpeg", @"url":@"http://ts1.mm.bing.net/th?id=H.4616249229050600&w=109&h=145&c=7&rs=1&pid=1.7"},
                     @{ @"name":@"name-sample_2.jpeg", @"url":@"http://ts2.mm.bing.net/th?id=H.4684302965671129&w=200&h=145&c=7&rs=1&pid=1.7"},
                     @{ @"name":@"name-sample_3.jpeg", @"url":@"http://ts2.mm.bing.net/th?id=H.4866306521369249&w=249&h=155&c=7&rs=1&pid=1.7"},
                     @{ @"name":@"name-sample_4.jpeg", @"url":@"http://ts1.mm.bing.net/th?id=H.4728584091535132&w=208&h=151&c=7&rs=1&pid=1.7"},
                     @{ @"name":@"name-sample_5.jpeg", @"url":@"http://ts2.mm.bing.net/th?id=H.4904497335305733&w=222&h=135&c=7&rs=1&pid=1.7"},
                     @{ @"name":@"name-sample_6.jpeg", @"url":@"http://ts2.mm.bing.net/th?id=H.5000532789101397&w=220&h=146&c=7&rs=1&pid=1.7"},
                     @{ @"name":@"name-sample_6.jpeg", @"url":@"http://ts2.mm.bing.net/th?id=H.4845055009882817&w=221&h=146&c=7&rs=1&pid=1.7"},
                     @{ @"name":@"name-sample_6.jpeg", @"url":@"http://ts1.mm.bing.net/th?id=H.4573840716727463&pid=1.9&w=300&h=300&p=0"},
                     @{ @"name":@"name-sample_6.jpeg", @"url":@"http://ts2.mm.bing.net/th?id=H.4907069983819353&w=194&h=146&c=7&rs=1&pid=1.7"},
                     @{ @"name":@"name-sample_6.jpeg", @"url":@"http://ts1.mm.bing.net/th?id=H.5043869011348364&w=161&h=154&c=7&rs=1&pid=1.7"},
                     @{ @"name":@"name-sample_6.jpeg", @"url":@"http://ts1.mm.bing.net/th?id=H.4594465161085808&pid=1.9&w=300&h=300&p=0"},
                     @{ @"name":@"name-sample_6.jpeg", @"url":@"http://ts4.mm.bing.net/th?id=H.4681597146629555&w=177&h=149&c=7&rs=1&pid=1.7"},
                     @{ @"name":@"name-sample_6.jpeg", @"url":@"http://ts1.mm.bing.net/th?id=H.4630886486248195&pid=1.9&w=300&h=300&p=0"},
                     @{ @"name":@"name-sample_6.jpeg", @"url":@"http://ts1.mm.bing.net/th?id=H.4530835230425413&pid=1.9&w=300&h=300&p=0"},
                     @{ @"name":@"name-sample_6.jpeg", @"url":@"http://ts1.mm.bing.net/th?id=H.4980913397302872&pid=1.9&w=300&h=300&p=0"},
                     @{ @"name":@"name-sample_6.jpeg", @"url":@"http://ts1.mm.bing.net/th?id=H.4980913397302872&pid=1.9&w=300&h=300&p=0"},
                     ];
    //INFO_GOTOEDIT
    [self.tipTxts addObjectsFromArray: @[
     @{@"tip":@"log=science,表示\"科学,学科\"。psychology n 心理学（paych 心理+o+log+y) psychology n 心理学（paych 心理+o+log psychology n 心理学（paych 心理+o+logabcdefghigklmnopqrstuvwxyzxyz abc1 abc2 abc3 abc4 abc5 abc6"},
     @{@"tip":@"PSY鸟叔，心理变态"},
     @{@"tip":@"各种常见的学 psychology 心理学 chemistry 化学 physics 物理学 mathematics 数学 literature 文学 astronomy 天文学"},
     @{@"tip":@"psych=mind, logy=某种学问，关于mind的学问，心理学", @"adoptNum": @"28" , @"optTime":@"18000" },
     @{@"tip":INFO_GOTOEDIT},
     ]];
    [self.tipSentences addObjectsFromArray:@[
     @{@"sentence":@"It seems to me that the psychology is abundantly clear.\n在我看来，这种心理非常清楚。", @"mp3":@"http://media.engkoo.com:8129/en-us/2CC9D118D62C36D1CBF69744F3BC85F9.mp3"},
     @{@"sentence":@"It seems to me that the psychology is abundantly clear.\n在我看来，这种心理非常清楚。", @"mp3":@"http://media.engkoo.com:8129/en-us/2CC9D118D62C36D1CBF69744F3BC85F9.mp3"},
     @{@"sentence":@"It seems to me that the psychology is abundantly clear.\n在我看来，这种心理非常清楚。", @"mp3":@"http://media.engkoo.com:8129/en-us/2CC9D118D62C36D1CBF69744F3BC85F9.mp3"},
     @{@"sentence":@"It seems to me that the psychology is abundantlyA substitute teacher was trying to make use of her psychology background.\n代课教师试图运用她的心理学知识。", @"mp3":@"http://media.engkoo.com:8129/en-us/2CC9D118D62C36D1CBF69744F3BC85F9.mp3"},
     ]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/*
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //注册cell
    static NSString *CellIdentifier = cellTipimg;
    //iphone
    [self.tblTipimgsIphone registerClass:[PPImageScrollingTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    [self.tblTipimgsIphone setDelegate:self];
    [self.tblTipimgsIphone setDataSource:self];
    
    //控件属性设置
    self.lblHeaderTip = [[UILabel alloc] init];
    self.lblHeaderTip.textColor = [UIColor blackColor];
    self.lblHeaderTip.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblHeaderTip.numberOfLines = 0;

    [self drawMyView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) playWordMp3
{
    NSLog(@"title button has been touch");
    NSError *myerror = nil;
    NSData *mp3data = [[NSData alloc] initWithContentsOfFile:self.fayinMp3Url];
    if(!mp3data){
        NSLog(@"发音文件不存在! path[%@]", self.fayinMp3Url);
        return;
    }
    self.player = [[AVAudioPlayer alloc] initWithData:mp3data error:&myerror];
    [self.player setDelegate:self];
    if(self.player){
        if ([self.player prepareToPlay]) {
            [self.player setVolume:0.5f];
            if([self.player play]){
                NSLog(@"play successed. mp3url[%@]", self.fayinMp3Url);
            }else{
                NSLog(@"play failed! mp3url[%@]", self.fayinMp3Url);
            }
        }else{
            NSLog(@"player prepareToPlay failed! mp3url[%@]", self.fayinMp3Url);
        }
    }else{
        NSLog(@"player init failed! mp3url[%@] msg:[%@]",self.fayinMp3Url,[myerror description]);
    }
}

- (void) drawMyView
{
//    UIButton *btnCover = [[UIButton alloc] initWithFrame:CGRectZero];
//    if(_btnCover.superview){
//        NSLog(@"_btnConver remove from supper.");
//        [_btnCover removeFromSuperview];
//    }
    _btnCover = [[UIButton alloc] initWithFrame:CGRectZero];
    _btnCover.frame = CGRectMake(0, 0, 320, 540);
    [_btnCover setTitle:[self.word stringByAppendingString:@" 是什么意思？"] forState:UIControlStateNormal];
    [_btnCover setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _btnCover.backgroundColor = [UIColor whiteColor];
    [_btnCover addTarget:self action:@selector(drawMyViewReal:) forControlEvents:UIControlEventTouchUpInside];
    
    _btnCover.tintColor = [UIColor whiteColor];
    
    [self.view addSubview:_btnCover];
}

- (void)drawMyViewReal:(UIButton *)sender {
    [sender removeFromSuperview];
    
    //title显示当前正在学习或复习的单词
    NSString *title = [[self.word stringByAppendingString:@" "] stringByAppendingString:self.fayin];
    UIButton *btnTitle = [[UIButton alloc] init];
    [btnTitle setTitle:title forState:UIControlStateNormal];
    [btnTitle addTarget:self
                 action:@selector(playWordMp3)
       forControlEvents:UIControlEventTouchDown];
    [btnTitle setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [self.navigationItem setTitleView:btnTitle];
    
//    self.lblMeaning.text = self.comment;
//    self.lblStem.text= self.wordGern;
//    UILabel *lblM
//    UIFont *fontDetail = [UIFont fontWithName:@"Verdana" size:11];
    NSString *content = [@" " stringByAppendingString:[[self.comment stringByAppendingString:@"\n\n词根词源：\n"] stringByAppendingString:self.wordGern]];
    CGSize contentSize = [content sizeWithFont:self.fontDetail constrainedToSize:CGSizeMake(180, 400)  lineBreakMode:NSLineBreakByWordWrapping];//求文本的大小
    UILabel *lbltmp = [[UILabel alloc] init];
    lbltmp.font = self.fontDetail;
    lbltmp.text = content;
    lbltmp.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
    lbltmp.lineBreakMode = NSLineBreakByWordWrapping;
    lbltmp.numberOfLines = 0;
    lbltmp.backgroundColor = [UIColor clearColor];
    self.svMeaningStem.frame = CGRectMake(0, 0, 200, 400);
    self.svMeaningStem.contentSize = contentSize;//self.lblMeaningStemIphone.frame.size;
    for( UIView *subview in self.svMeaningStem.subviews){
        [subview removeFromSuperview];
    }
    [self.svMeaningStem addSubview:lbltmp];
//    self.lblMeaningStemIphone.font = [UIFont systemFontOfSize:12];
//    self.lblMeaningStemIphone.text = content;
//    self.lblMeaningStemIphone.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
//    self.lblMeaningStemIphone.lineBreakMode = NSLineBreakByWordWrapping;
//    self.lblMeaningStemIphone.numberOfLines = 0;
//    self.lblMeaningStemIphone.backgroundColor = [UIColor clearColor];
//    self.svMeaningStem.contentSize = contentSize;//self.lblMeaningStemIphone.frame.size;
//    if(self.lblMeaningStemIphone.superview != self.svMeaningStem){
//        [self.svMeaningStem addSubview:self.lblMeaningStemIphone];
//    }
    //读图片
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                       , NSUserDomainMask
                                                       , YES);
    NSString *filepath = [[paths objectAtIndex:0] stringByAppendingPathComponent:self.word];
    NSLog(@"load filepath[%@]", filepath);
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if([filemanager fileExistsAtPath: filepath]){
        NSData *imagedata = [NSData dataWithContentsOfFile:filepath];
        UIImage *wordImg = [UIImage imageWithData:imagedata];
        [self.btnTipImgIphone setImage:wordImg forState:UIControlStateHighlighted];
        [self.btnTipImgIphone setImage:wordImg forState:UIControlStateNormal];
    }
        
    //iphone－tip sentence 的multisagetableview
    CGRect mFrame = CGRectMake(0.0, 0.0, self.svExpFrame.size.width, self.svExpFrame.size.height);
    self.tblMultipsIphone = [[TQMultistageTableView alloc] initWithFrame: mFrame];
    self.tblMultipsIphone.delegate = self;
    self.tblMultipsIphone.dataSource = self;
    self.tblTipimgsIphone.hidden = TRUE;
    self.vtip.frame = self.svExpFrame;
    [self.vtip addSubview:self.tblMultipsIphone]; 
}

-(void) popLoginView:(int)popType
{
    CGFloat xWidth = self.view.bounds.size.width - 80.0f;
    CGFloat yHeight = HEIGHT_LOGIN;
    CGFloat yOffset = (self.view.bounds.size.height - yHeight - 100)/2.0f;
    UIPopoverListView *poplistview = [[UIPopoverListView alloc] initWithFrameType:CGRectMake(10, yOffset, xWidth, yHeight) popType:popType];
    poplistview.delegate = self;
    [poplistview show];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //用户选择自己编辑助记
    if([segue.identifier isEqualToString:SEGUE_EDIT])
    {
        NSString *content = [@" " stringByAppendingString:[[self.comment stringByAppendingString:@"\n\n词根词源：\n"] stringByAppendingString:self.wordGern]];
        [segue.destinationViewController setWord:self.word];
        [segue.destinationViewController setMeaningstem:content];
        [segue.destinationViewController setTipTxtOld:self.tipTxt];
        [segue.destinationViewController setDelegate:self];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == self.tblTipimgsIphone){
        return 1;
    }else{
        NSLog(@"DANCI WARNING: see sections. tableview is Nagative! tableViewId[%@]", tableView.restorationIdentifier);
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.tblTipimgsIphone){
        return 1;
    }else{
        NSLog(@"DANCI WARNING: see sections. tableview is Nagative! tableViewId[%@]", tableView.restorationIdentifier);
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if(tableView == self.tblTipimgsIphone){
        //显示图片
        static NSString *CellIdentifier = cellTipimg;
        PPImageScrollingTableViewCell *customCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        NSArray *cellData = self.tipImgs;
        [customCell setBackgroundColor:[UIColor grayColor]];
        [customCell setDelegate:self];
        [customCell setImageData:cellData];
//        [customCell setCategoryLabelText:[cellData objectForKey:@"category"] withColor:[UIColor whiteColor]];
//        [customCell setTag:[indexPath section]];
//        [customCell setImageTitleTextColor:[UIColor whiteColor] withBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
//        [customCell setImageTitleLabelWitdh:90 withHeight:45];
        [customCell setCollectionViewBackgroundColor:[UIColor darkGrayColor]];
        return customCell;
    }else{
        NSLog(@"DANCI WARNING: loading cell. tableview is Nagative! tableViewId[%@]", tableView.restorationIdentifier);
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //图片的tableView需要150的宽度。ipad下可以考虑更大。其他默认
    if(tableView == self.tblTipimgsIphone){
        return HEIGHT_IMG_ROW;
    }else{
        return 50.0f;
    }
}

#pragma mark - PPImageScrollingTableViewCellDelegate

//用户选择了一个图片之后
- (void)scrollingTableViewCell:(PPImageScrollingTableViewCell *)sender didSelectImageAtIndexPath:(NSIndexPath*)indexPathOfImage
{
    //判断是否登陆
    if(self.userMid == nil){
        [self popLoginView:TYPE_LOGIN];
        return;
    }
    NSString *imgName = [[self.tipImgs objectAtIndex:indexPathOfImage.row]objectForKey:@"name"];
    NSString *imgUrl = [[self.tipImgs objectAtIndex:indexPathOfImage.row] objectForKey:@"url"];
    PPCollectionViewCell *cell = (PPCollectionViewCell *) [sender.imageScrollingView.myCollectionView cellForItemAtIndexPath:indexPathOfImage];
    NSData *imgData = UIImageJPEGRepresentation(cell.imageView.image, 0.0f);
    UIImage *img = [UIImage imageWithData:imgData];
    [self.btnTipImgIphone setImage:img forState:UIControlStateNormal];
    [self.btnTipImgIphone setImage:img forState:UIControlStateHighlighted];
    NSLog(@"selected img info: imgName:[%@] imgUrl:[%@]", imgName, imgUrl);
    
    //图片保存到本地
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileName = [[[paths objectAtIndex:0] stringByAppendingString:@"/" ] stringByAppendingString:self.word];
    if([imgData length] > 0 && [imgData writeToFile:fileName atomically:YES]){
        NSLog(@"write img ok. word[%@] filename[%@]", self.word, fileName);
    }else{
        NSLog(@"write img failed! word[%@] filename[%@]", self.word, fileName);
    }
    //将采纳发送到server
    //发送失败则写入本地
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat: @"Image %@",imgName]
//                                                    message:[NSString stringWithFormat: @"in %@",imgUrl]
//                                                   delegate:self
//                                          cancelButtonTitle:@"OK"
//                                          otherButtonTitles: nil];
//    [alert show];
}

#pragma mark - TQMultistageTableView datasource
- (NSInteger)numberOfSectionsInMTableView:(TQMultistageTableView *)tableView
{
    //第一个section是tipxtxt； 第二个section是sentence
    return 2;
}

- (NSInteger)mTableView:(TQMultistageTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return [self.tipTxts count];
    }else{
        return [self.tipSentences count];
    }
}

- (UITableViewCell *)mTableView:(TQMultistageTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"TQMultistageTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        NSLog(@"init a cell. section[%d] row[%d]", indexPath.section, indexPath.row);
    }
    UIView *view = [[UIView alloc] initWithFrame:cell.bounds] ;
    
    view.backgroundColor = [UIColor colorWithRed:128/255.0 green:156/255.0 blue:151/255.0 alpha:1];
    cell.backgroundView = view;
    
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    //加载tips
    if(indexPath.section == 0){
        NSString *tip = [[self.tipTxts objectAtIndex:indexPath.row] objectForKey:@"tip"];
        cell.textLabel.font = self.fontDetail;
        if([tip isEqualToString:INFO_GOTOEDIT]){
            cell.textLabel.font = [UIFont fontWithName:@"Verdana" size:13];
//            cell.textLabel.textColor = [UIColor lightGrayColor];
        }
        else{
            cell.textLabel.font = self.fontDetail;
        }
        cell.textLabel.text = tip;
    }else{
        //加载sentence
        cell.textLabel.font = self.fontDetail;
        cell.textLabel.text = [[self.tipSentences objectAtIndex:indexPath.row] objectForKey:@"sentence"];
    }
    
    return cell;
}

- (UIView *)mTableView:(TQMultistageTableView *)tableView openCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 100)];
    view.backgroundColor = [UIColor colorWithRed:187/255.0 green:206/255.0 blue:190/255.0 alpha:1];;
    return view;
}

#pragma mark - TQMultistageTableView delegate
- (CGFloat)mTableView:(TQMultistageTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HEIGHT_TQ_ROW;
}

- (CGFloat)mTableView:(TQMultistageTableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0 && [self.tipTxt length] > 0){
//        NSLog(@"height for section0");
        return HEIGHT_TIP_TXT;
    }else{
//        NSLog(@"height for section[%d]", section);
        return HEIGHT_SENTENCE;
    }
}

- (CGFloat)mTableView:(TQMultistageTableView *)tableView heightForOpenCellAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"height for row[%@]", indexPath);
    return HEIGHT_TQ_CELL;
}

- (UIView *)mTableView:(TQMultistageTableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //http://blog.csdn.net/onlyou930/article/details/7422097
    UIFont *fontTitle = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
//    UIFont *fontDetail = [UIFont fontWithName:@"Verdana" size:11];
    UIView * control = [[UIView alloc] init];
    control.backgroundColor = [UIColor whiteColor];
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor blackColor];
    UILabel *labelPin = [[UILabel alloc] init];
    labelPin.text = @">";
    labelPin.textColor = [UIColor greenColor];
    if(section == 0){
        if([self.tipTxt length] > 1){
            self.lblHeaderTip.font = self.fontDetail;
            self.lblHeaderTip.text = [@"助记：" stringByAppendingString: self.tipTxt];
            self.lblHeaderTip.frame = CGRectMake(20, 0, tableView.frame.size.width, HEIGHT_TIP_TXT - 2);
            view.frame = CGRectMake(0, HEIGHT_TIP_TXT - 2, tableView.frame.size.width,2);
            labelPin.frame = CGRectMake(0, 0, 20, HEIGHT_TIP_TXT - 2);
        }else{
            self.lblHeaderTip.text = @"采纳助记";
            self.lblHeaderTip.frame = CGRectMake(20, 0, 200, HEIGHT_SENTENCE - 2);
            view.frame = CGRectMake(0, HEIGHT_SENTENCE - 2, tableView.frame.size.width,2);
            labelPin.frame = CGRectMake(0, 0, 20, HEIGHT_TIP_TXT - 2);
        }
        [control addSubview:labelPin];
        [control addSubview:self.lblHeaderTip];
    }else{
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor blackColor];
        label.font = fontTitle;
        label.text = @"例句";
        label.frame = CGRectMake(20, 0, 200, HEIGHT_SENTENCE - 2);
        view.frame = CGRectMake(0, HEIGHT_SENTENCE - 2, tableView.frame.size.width,2);
        labelPin.frame = CGRectMake(0, 0, 20, HEIGHT_SENTENCE - 2);
        [control addSubview:labelPin];
        [control addSubview:label];
    }
    [control addSubview:view];
    return control;
}

- (void)mTableView:(TQMultistageTableView *)tableView didSelectHeaderAtSection:(NSInteger)section
{
//    NSLog(@"headerClick%d",section);
}

//celll点击
- (void)mTableView:(TQMultistageTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellClick%@",indexPath);
    if(indexPath.section == 0){
        if(self.userMid == nil){
            [self popLoginView:TYPE_LOGIN];
            return;
        }
        //tiptxt的采纳
        NSString *tipadopt = [[self.tipTxts objectAtIndex:indexPath.row] objectForKey:@"tip"];
        //若选择的是自己编辑助记
        if([tipadopt isEqualToString:INFO_GOTOEDIT])
        {
            [self performSegueWithIdentifier:SEGUE_EDIT sender:self];
        }
        else
        {
            if(![tipadopt isEqualToString:self.tipTxt]){
                NSLog(@"新采纳助记 old[%@] new[%@]", self.tipTxt, tipadopt);
                self.tipTxt = tipadopt;
                self.lblHeaderTip.text = [@"助记：" stringByAppendingString: self.tipTxt];
                //更新到server
            }else{
                NSLog(@"采纳助记无变化 old[%@] new[%@]", self.tipTxt, tipadopt);
            }
        }
    }else if(indexPath.section ==1){
        //sentence的选择。
    }
}

//header展开
- (void)mTableView:(TQMultistageTableView *)tableView willOpenHeaderAtSection:(NSInteger)section
{
    NSLog(@"headerOpencc%d",section);
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [self.tblTipimgsIphone.layer addAnimation:animation forKey:nil];
    self.tblTipimgsIphone.hidden = TRUE;
    self.vtip.frame = self.svExpFrame;
    CGRect mFrame = CGRectMake(0.0, 0.0, self.svExpFrame.size.width, self.svExpFrame.size.height - HEIGHT_TIP_TXT);
    self.tblMultipsIphone.frame = mFrame;
    [UIView commitAnimations];
    
//    NSLog(@"header展开 frame of vtip: x:[%f] y[%f] width[%f] height[%f]",self.vtip.frame.origin.x, self.vtip.frame.origin.y,self.vtip.frame.size.width,self.vtip.frame.size.height);
//    NSLog(@"header展开 frame of tblMultipsIphone: x:[%f] y[%f] width[%f] height[%f]",self.tblMultipsIphone.frame.origin.x, self.tblMultipsIphone.frame.origin.y,self.tblMultipsIphone.frame.size.width,self.tblMultipsIphone.frame.size.height);
}

//header关闭
- (void)mTableView:(TQMultistageTableView *)tableView willCloseHeaderAtSection:(NSInteger)section
{
//    NSLog(@"headerClose%d",section);
//    NSLog(@"header关闭 frame of vtip: x:[%f] y[%f] width[%f] height[%f]",self.vtip.frame.origin.x, self.vtip.frame.origin.y,self.vtip.frame.size.width,self.vtip.frame.size.height);
//    NSLog(@"header关闭 frame of tblMultipsIphone: x:[%f] y[%f] width[%f] height[%f]",self.tblMultipsIphone.frame.origin.x, self.tblMultipsIphone.frame.origin.y,self.tblMultipsIphone.frame.size.width,self.tblMultipsIphone.frame.size.height);
//    //show the tbl
//    CATransition *animation = [CATransition animation];
//    animation.type = kCATransitionFade;
//    animation.duration = 0.5;
//    [self.tblTipimgsIphone.layer addAnimation:animation forKey:nil];
//    self.tblTipimgsIphone.hidden = FALSE;
//    self.vtip.frame = self.svNormFrame;
}

- (void)mTableView:(TQMultistageTableView *)tableView willOpenCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"OpenCell%@",indexPath);
    
    if(indexPath.section == 1){
        //播放例句发音
        NSString *mp3url = [[self.tipSentences objectAtIndex:[indexPath row]] objectForKey:@"mp3"];
        dispatch_queue_t play_q = dispatch_queue_create("play mp3", NULL);
        dispatch_async(play_q, ^{
            NSURL *mp3urlNet = [NSURL URLWithString:mp3url];
            NSData *mp3data = [[NSData alloc] initWithContentsOfURL:mp3urlNet];
            NSError *myerror = nil;
            self.player = [[AVAudioPlayer alloc] initWithData:mp3data error:&myerror];
            [self.player setDelegate:self];
            if(self.player){
                if ([self.player prepareToPlay]) {
                    [self.player setVolume:0.5f];
                    if([self.player play]){
                        NSLog(@"play successed. mp3url[%@]", mp3url);
                    }else{
                        NSLog(@"play failed! mp3url[%@]", mp3url);
                    }
                }else{
                    NSLog(@"player prepareToPlay failed! mp3url[%@]", mp3url);
                }
            }else{
                NSLog(@"player init failed! mp3url[%@] msg:[%@]",mp3url,[myerror description]);
            }
        });
    }
}

- (void)mTableView:(TQMultistageTableView *)tableView willCloseCellAtIndexPath:(NSIndexPath *)indexPath;
{
//    NSLog(@"CloseCell%@",indexPath);
}

#pragma mark - popListViewDelegate

-(void) popoverListViewCancel:(UIPopoverListView *)popoverListView
{
    //应该纪录下来 计算流失率
    NSLog(@"user do not want to reg or login");
}

-(void) popoverListViewLogin:(UIPopoverListView *)popoverListView oldUser:(NSDictionary *)userInfo
{
    self.userMid = [userInfo objectForKey:@"userMid"];
    NSLog(@"user login in");
}

-(void) popoverListViewRegist:(UIPopoverListView *)popoverListView newUser:(NSDictionary *)userInfo
{
    self.userMid = [userInfo objectForKey:@"userMid"];
    NSLog(@"user regist. ");
}

#pragma mark - DanciEditTipTxtDelegate

-(void) eidtTipTxt:(DanciEditTipTxtViewController *)sender didEditTipTxtOk:(NSString *)tipTxt
{
    self.tipTxt = tipTxt;
    //设置view的相关控件
    self.lblHeaderTip.text = tipTxt;
}

#pragma mark - videoplaydelegate

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"播放完毕 %d",flag);
}

#pragma mark - event hander

- (IBAction)showImgTips:(id)sender {
    //show the tbl
    if(self.tblTipimgsIphone.hidden){
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionFade;
        animation.duration = 0.5;
        [self.tblTipimgsIphone.layer addAnimation:animation forKey:nil];
        self.tblTipimgsIphone.hidden = FALSE;
        self.vtip.frame = self.svNormFrame;
        CGRect mFrame = CGRectMake(0.0, 0.0, self.svNormFrame.size.width, self.svNormFrame.size.height - self.svExpFrame.origin.y);
        self.tblMultipsIphone.frame = mFrame;
        NSLog(@"showImgTips frame of vtip: x:[%f] y[%f] width[%f] height[%f]",self.vtip.frame.origin.x, self.vtip.frame.origin.y,self.vtip.frame.size.width,self.vtip.frame.size.height);
        NSLog(@"showImgTips frame of tblMultipsIphone: x:[%f] y[%f] width[%f] height[%f]",self.tblMultipsIphone.frame.origin.x, self.tblMultipsIphone.frame.origin.y,self.tblMultipsIphone.frame.size.width,self.tblMultipsIphone.frame.size.height);
    }
}

- (IBAction)showNextWord:(UIButton *)sender {
    self.wordPoint += 1;
    NSLog(@"reflush .. now wordPoint[%d] album length[%d]", self.wordPoint, [self.words count]);
    if(self.wordPoint < [self.words count]){
        [self.view setNeedsDisplay];
        [self drawMyView];
    }else{
        NSLog(@"all words of current album has Done!");
    }
}

@end

