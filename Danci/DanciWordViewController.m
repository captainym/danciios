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
#import "DanciServer.h"


@interface DanciWordViewController () <PPImageScrollingTableViewCellDelegate, UITableViewDataSource,UITableViewDelegate,AVAudioPlayerDelegate , UIPopoverListViewDelegate, DanciEditTipTxtDelegate>

@end

@implementation DanciWordViewController

#pragma mark - properties synthesize
@synthesize isNewStudy = _isNewStudy;
@synthesize userMid = _userMid;

@synthesize words = _words;
@synthesize wordsReviewNow = _wordsReviewNow;
@synthesize pointReviewNow = _pointCurReview;
@synthesize word = _word;
@synthesize tipImgs = _tipImgs;
@synthesize tipSentences = _tipSentences;
@synthesize player = _player;
//@synthesize svExpFrame = _svExpFrame;
//@synthesize svNormFrame = _svNormFrame;
@synthesize fontDetail = _fontDetail;
@synthesize wordTerm = _wordTerm;

#pragma mark- properties lazy load

- (void) setAlbum:(Album *)album
{
    _album = album;
    self.words = [self.album.words componentsSeparatedByString:@"|"];
    NSLog(@"setAlbum 从album中分离出[%d]个word wordsList[%@]", [_words count], self.album.words);
    //设置第一个word
    int curPoint = [self.album.point intValue] % [self.album.count intValue];
    self.wordTerm = [self.words objectAtIndex:curPoint];
}

- (void) setWordTerm:(NSString *)wordTerm
{
    _wordTerm = wordTerm;
    [self getWordInfo];
}

- (NSMutableArray *) tipImgs
{
    if(!_tipImgs){
        _tipImgs = [[NSMutableArray alloc] init];
    }
    
    return _tipImgs;
}

- (NSString *) fayinMp3Url
{
    //假数据 实际是按照一定规则生成
    _fayinMp3Url = @"/Users/huhao/Developer/psychology.mp3";
    return _fayinMp3Url;
}

- (NSString *) tipImgFilepath
{
    NSString *docpath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                       , NSUserDomainMask
                                                       , YES) lastObject];
    _tipImgFilepath = [docpath stringByAppendingPathComponent:self.word.word];
    return _tipImgFilepath;
}

//-(CGRect) svExpFrame
//{
//    if(_svExpFrame.origin.x < 1){
//        _svExpFrame = CGRectMake(3.0, 166, 314, 350);
//        NSLog(@"after _svExpFrame. x[%f] y[%f] height[%f] width[%f]",_svExpFrame.origin.x,_svExpFrame.origin.y,_svExpFrame.size.height,_svExpFrame.size.width);
//    }
//    return _svExpFrame;
//}
//
//-(CGRect) svNormFrame
//{
//    if(_svNormFrame.origin.x < 1){
//        _svNormFrame = CGRectMake(3.0, 269, 314, 250);
//        NSLog(@"after _svNormFrame. x[%f] y[%f] height[%f] width[%f]",_svNormFrame.origin.x,_svNormFrame.origin.y,_svNormFrame.size.height,_svNormFrame.size.width);
//    }
//    return _svNormFrame;
//}

-(NSString *) userMid
{
    if([_userMid length] < 1 ){
        //core data 取值
//        _userMid = @"18601920512";
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

-(void) setTipSentences:(NSArray *)tipSentences
{
    _tipSentences = tipSentences;
    //完成后 通知tblsentence更新
    [self.tblTipSentence reloadData];
}

#pragma mark -  methods

- (void) reloadTipimgsForWord:(NSString *) wordTerm atBegin:(int) begin requestCount:(int) count
{
    dispatch_queue_t queueImg = dispatch_queue_create("downloadTipimg", NULL);
    dispatch_async(queueImg, ^{
        NSArray *tmpimgs = [DanciServer getWordTipsImg:wordTerm atBegin:begin requestCount:count];
        [self.tipImgs addObjectsFromArray:tmpimgs];
        //完成后通知tblimg更新
        [self.tblTipimgsIphone reloadData];
    });
}

- (void) reloadTipsentenceForWord:(NSString *)wordTerm
{
    dispatch_queue_t queueSentence = dispatch_queue_create("downloadSentence", NULL);
    dispatch_async(queueSentence, ^{
        self.tipSentences = [DanciServer getWordTipsSentence:wordTerm];
    });
}

//从coredata中取出当前word的各种信息： 发音 真人发音mp3 中文释义 词根词缀 例句 例句mp3地址 从网络获取tipImgs tipTxts 例句mp3
- (void) getWordInfo
{
    self.word = [Word getWord:self.wordTerm inManagedObjectContext:self.danciDatabase.managedObjectContext];
    NSLog(@"word:[%@]", self.word);
    [self reloadTipimgsForWord:self.word.word atBegin:0 requestCount:DEFAULT_REQUEST_COUNT_IMG];
    [self reloadTipsentenceForWord:self.word.word];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //注册cell
    static NSString *cellIdTipimg = CELL_ID_TIPIMG;
    [self.tblTipimgsIphone registerClass:[PPImageScrollingTableViewCell class] forCellReuseIdentifier:cellIdTipimg];
    [self.tblTipimgsIphone setDelegate:self];
    [self.tblTipimgsIphone setDataSource:self];

    [self.tblTipSentence setDelegate:self];
    [self.tblTipSentence setDataSource:self];

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
    _btnCover = [[UIButton alloc] initWithFrame:CGRectZero];
    _btnCover.frame = CGRectMake(0, 0, 320, 540);
    [_btnCover setTitle:[self.word.word stringByAppendingString:@" 是什么意思？"] forState:UIControlStateNormal];
    [_btnCover setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _btnCover.backgroundColor = [UIColor whiteColor];
    [_btnCover addTarget:self action:@selector(drawMyViewReal:) forControlEvents:UIControlEventTouchUpInside];
    
    _btnCover.tintColor = [UIColor whiteColor];
    
    [self.view addSubview:_btnCover];
}

- (void)drawMyViewReal:(UIButton *)sender {
    [sender removeFromSuperview];
    
    //title显示当前正在学习或复习的单词
    NSString *title = [[self.word.word stringByAppendingString:@" "] stringByAppendingString:self.word.yin_biao];
    UIButton *btnTitle = [[UIButton alloc] init];
    [btnTitle setTitle:title forState:UIControlStateNormal];
    [btnTitle addTarget:self
                 action:@selector(playWordMp3)
       forControlEvents:UIControlEventTouchDown];
    [btnTitle setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [self.navigationItem setTitleView:btnTitle];
    
    self.lblMeaning.text = self.word.meaning;
    
    NSString *tip = @"";
    if([self.word.stem length] > 1){
        tip = [@"词根：" stringByAppendingString:self.word.stem];
    }
    if([self.word.txt_tip length] > 1){
        tip = [tip stringByAppendingString:@"\n助记："];
        tip = [tip stringByAppendingString:self.word.txt_tip];
    }
    
    //读图片
    NSLog(@"load filepath[%@]", self.tipImgFilepath);
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if([filemanager fileExistsAtPath: self.tipImgFilepath]){
        NSData *imagedata = [NSData dataWithContentsOfFile:self.tipImgFilepath];
        UIImage *wordImg = [UIImage imageWithData:imagedata];
        [self.btnTipImgIphone setImage:wordImg forState:UIControlStateHighlighted];
        [self.btnTipImgIphone setImage:wordImg forState:UIControlStateNormal];
    }
        
    //iphone－tip sentence 的multisagetableview
//    self.tblTipimgsIphone.hidden = TRUE;
//    self.vtip.frame = self.svExpFrame;
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
        //传递参数有是word
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.tblTipimgsIphone){
        return 1;
    } else if(tableView == self.tblTipSentence){
        return [self.tipSentences count];
    } else{
        NSLog(@"DANCI WARNING: see sections. tableview is Nagative! tableViewId[%@]", tableView.restorationIdentifier);
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if(tableView == self.tblTipimgsIphone){
        //显示图片
        static NSString *CellIdentifier = CELL_ID_TIPIMG;
        PPImageScrollingTableViewCell *customCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        NSArray *cellData = self.tipImgs;
        [customCell setBackgroundColor:[UIColor grayColor]];
        [customCell setDelegate:self];
        [customCell setImageData:cellData];
        [customCell setCollectionViewBackgroundColor:[UIColor darkGrayColor]];
        return customCell;
    }else if(tableView == self.tblTipSentence){
        cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_TIPSENTENCE forIndexPath:indexPath];
        NSString *sentence = [[self.tipSentences objectAtIndex:indexPath.row] objectForKey:TIPS_SENTENCE_SENTENCE];
        NSString *meaning = [[self.tipSentences objectAtIndex:indexPath.row] objectForKey:TIPS_SENTENCE_MEANING];
        cell.textLabel.font = self.fontDetail;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.text = [[sentence stringByAppendingString:@"\n"] stringByAppendingString:meaning];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //图片的tableView需要150的宽度。ipad下可以考虑更大。其他默认
    if(tableView == self.tblTipimgsIphone){
        return HEIGHT_IMG_ROW;
    }else if(tableView == self.tblTipSentence){
        return HEIGHT_SENTENCE_ROW;
    }else{
        return 0.0f;
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
    NSString *imgName = [[self.tipImgs objectAtIndex:indexPathOfImage.row]objectForKey:TIPS_IMG_NAME];
    NSString *imgUrl = [[self.tipImgs objectAtIndex:indexPathOfImage.row] objectForKey:TIPS_IMG_URL];
    PPCollectionViewCell *cell = (PPCollectionViewCell *) [sender.imageScrollingView.myCollectionView cellForItemAtIndexPath:indexPathOfImage];
    NSData *imgData = UIImageJPEGRepresentation(cell.imageView.image, 0.0f);
    UIImage *img = [UIImage imageWithData:imgData];
    [self.btnTipImgIphone setImage:img forState:UIControlStateNormal];
    [self.btnTipImgIphone setImage:img forState:UIControlStateHighlighted];
    NSLog(@"selected img info: imgName:[%@] imgUrl:[%@]", imgName, imgUrl);
    
    //图片保存到本地
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileName = [[[paths objectAtIndex:0] stringByAppendingString:@"/" ] stringByAppendingString:self.word.word];
    if([imgData length] > 0 && [imgData writeToFile:fileName atomically:YES]){
        NSLog(@"write img ok. word[%@] filename[%@]", self.word, fileName);
    }else{
        NSLog(@"write img failed! word[%@] filename[%@]", self.word, fileName);
    }
    //将采纳发送到server
#pragma warning - not compliment
    //发送失败则写入本地
#pragma warning - not compliment
}

//关闭图片选择 放大tip内容
- (void)closeTipsimgAndMaxTipsentence
{
//    CATransition *animation = [CATransition animation];
//    animation.type = kCATransitionFade;
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.4];
//    [self.tblTipimgsIphone.layer addAnimation:animation forKey:nil];
//    self.tblTipimgsIphone.hidden = TRUE;
//    self.vtip.frame = self.svExpFrame;
//    [UIView commitAnimations];
    
//    NSLog(@"header展开 frame of vtip: x:[%f] y[%f] width[%f] height[%f]",self.vtip.frame.origin.x, self.vtip.frame.origin.y,self.vtip.frame.size.width,self.vtip.frame.size.height);
//    NSLog(@"header展开 frame of tblMultipsIphone: x:[%f] y[%f] width[%f] height[%f]",self.tblMultipsIphone.frame.origin.x, self.tblMultipsIphone.frame.origin.y,self.tblMultipsIphone.frame.size.width,self.tblMultipsIphone.frame.size.height);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tblTipSentence){
        //播放例句发音
        NSString *mp3url = [[self.tipSentences objectAtIndex:[indexPath row]] objectForKey:TIPS_SENTENCE_MP3];
        dispatch_queue_t play_q = dispatch_queue_create("playmp3", NULL);
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
    self.word.txt_tip = tipTxt;
    //设置view的相关控件
    NSString *tip = @"";
    if([self.word.stem length] > 1){
        tip = [@"词根：" stringByAppendingString:self.word.stem];
    }
    if([self.word.txt_tip length] > 1){
        tip = [tip stringByAppendingString:@"\n助记："];
        tip = [tip stringByAppendingString:self.word.txt_tip];
    }
}

#pragma mark - videoplaydelegate

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"播放完毕 %d",flag);
}

#pragma mark - event hander

- (IBAction)showImgTips:(id)sender {
    //show the tbl
//    if(self.tblTipimgsIphone.hidden){
//        CATransition *animation = [CATransition animation];
//        animation.type = kCATransitionFade;
//        animation.duration = 0.5;
//        [self.tblTipimgsIphone.layer addAnimation:animation forKey:nil];
//        self.tblTipimgsIphone.hidden = FALSE;
//        self.vtip.frame = self.svNormFrame;
////        CGRect mFrame = CGRectMake(0.0, 0.0, self.svNormFrame.size.width, self.svNormFrame.size.height - self.svExpFrame.origin.y);
////        self.tblMultipsIphone.frame = mFrame;
//        NSLog(@"showImgTips frame of vtip: x:[%f] y[%f] width[%f] height[%f]",self.vtip.frame.origin.x, self.vtip.frame.origin.y,self.vtip.frame.size.width,self.vtip.frame.size.height);
//    }
}

- (IBAction)showNextWord:(UIButton *)sender {
    self.album.point = [NSNumber numberWithInt:([self.album.point intValue] + 1)];
    NSLog(@"reflush .. now wordPoint[%d] album length[%d]", [self.album.point intValue], [self.words count]);
    if([self.album.point intValue] != [self.words count]){
        int curPoint = [self.album.point intValue] % [self.album.count intValue];
        self.wordTerm = [self.words objectAtIndex:curPoint];
        [self.view setNeedsDisplay];
        [self drawMyView];
    }else{
        NSLog(@"all words of current album has Done! You can just begin next cycle!");
    }
}

@end

