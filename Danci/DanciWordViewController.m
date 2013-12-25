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
#import "StudyOperation+Server.h"
#import "StudyOperation+Server.h"

#define WORD_SEPARATED @"|"
#define NUM_LEANING_GROUP 5
#define NUM_NEED_REVIEW_FUZZLE 3
#define NUM_NEED_REVIEW_NO 3
#define NUM_NEED_REVIEW_NOANDFUZZLE 4
#define FILE_TIP_IMG_DEFAULT @"default"

@interface DanciWordViewController () <PPImageScrollingTableViewCellDelegate, UITableViewDataSource,UITableViewDelegate,AVAudioPlayerDelegate , UIPopoverListViewDelegate, DanciEditTipTxtDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSString *tips;
//新单词学习计数器
@property int counter;
//单词复习队列1和2 确保每个单词都有3次复习机会（包括第一次学习）
@property (nonatomic, strong) NSMutableArray *reviewNo;
@property (nonatomic, strong) NSMutableArray *reviewFuzze;
//默认的tip图片
@property (nonatomic, strong) UIImage *defaultTipImg;
@property (nonatomic, strong) NSString *msgReview;

@end

@implementation DanciWordViewController

#pragma mark - properties synthesize
@synthesize isNewStudy = _isNewStudy;
@synthesize user = _user;
@synthesize wordsHasStudied = _wordsHasStudied;
@synthesize tips = _tips;

@synthesize words = _words;
@synthesize wordsReviewNow = _wordsReviewNow;
@synthesize pointReviewNow = _pointCurReview;
@synthesize word = _word;
@synthesize tipImgs = _tipImgs;
@synthesize tipSentences = _tipSentences;
@synthesize player = _player;
@synthesize fontDetail = _fontDetail;
@synthesize wordTerm = _wordTerm;
@synthesize reviewNo = _reviewNo;
@synthesize reviewFuzze = _reviewFuzze;
@synthesize msgReview = _msgReview;

@synthesize defaultTipImg = _defaultTipImg;

#pragma mark- properties lazy load

-(UIImage *) defaultTipImg
{
    if(_defaultTipImg == nil){
        NSString *defaultImgFile = [[NSBundle mainBundle] pathForResource:FILE_TIP_IMG_DEFAULT ofType:@"jpg"];
        NSData *imgData = [[NSData alloc] initWithContentsOfFile:defaultImgFile];
        _defaultTipImg = [[UIImage alloc] initWithData:imgData];
    }
    
    return _defaultTipImg;
}

- (NSMutableArray *) reviewNo
{
    if(_reviewNo == nil){
        _reviewNo = [[NSMutableArray alloc] init];
    }
    return _reviewNo;
}

- (NSMutableArray *) reviewFuzze
{
    if(_reviewFuzze == nil){
        _reviewFuzze = [[NSMutableArray alloc] init];
    }
    return _reviewFuzze;
}


- (UserInfo *) user
{
    if(_user == nil){
        _user = [UserInfo getUser:self.danciDatabase.managedObjectContext];
    }
    return _user;
}

- (void) setAlbum:(Album *)album
{
    _album = album;
    self.words = [self.album.words componentsSeparatedByString:@"|"];
    NSLog(@"setAlbum 从album中分离出[%d]个word wordsList[%@]", [_words count], self.album.words);
    //设置第一个word
    int curPoint = ([self.album.point intValue] - 1) % [self.album.count intValue];
    self.msgReview = @"";
    self.wordTerm = [self.words objectAtIndex:curPoint];
}

- (NSString *) tips
{
    _tips = @"";
    if([self.word.stem length] > 1){
        _tips = [@"词根：" stringByAppendingString:self.word.stem];
        if([[self.word.stem substringToIndex:3] isEqualToString:@" 词根"]){
            _tips = self.word.stem;
        }
    }
    if([self.word.txt_tip length] > 1){
        _tips = [[_tips stringByAppendingString:@"\n助记："] stringByAppendingString:self.word.txt_tip];
    }
    if([_tips length] < 1){
        _tips = @"可选择或编辑助记：轻戳右边的“...”";
    }
    //trim
    _tips = [_tips stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return _tips;
}

- (void) setWordTerm:(NSString *)wordTerm
{
    _wordTerm = wordTerm;
    [_tipImgs removeAllObjects];
    [self.tblTipimgsIphone reloadData];
    _tipSentences = nil;
    [self.tblTipSentence reloadData];
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
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"words_voices" ofType:nil];
    _fayinMp3Url = [bundlePath stringByAppendingFormat:@"/%@/%@.mp3", [self.wordTerm substringToIndex:1] , self.wordTerm];
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
}

#pragma mark -  methods

//判断单词是否学习过。如果没有 则学习并消耗单词上限，同时更新user信息
- (BOOL) isWordStudiedOtherwiseAdd:(NSString *)wordTerm
{
    if(_wordsHasStudied == nil){
        _wordsHasStudied = [[NSMutableSet alloc] initWithArray:[self.user.words componentsSeparatedByString:WORD_SEPARATED]];
        NSLog(@"init wordStudied. count[%d], words[%@]",[_wordsHasStudied count],self.user.words);
    }
    
    if([self.wordsHasStudied containsObject:wordTerm]){
        NSLog(@"word has studied before. word[%@]",wordTerm);
        return TRUE;
    }else{
        NSLog(@"word has not been studied. word[%@]",wordTerm);
        [self.wordsHasStudied addObject:wordTerm];
        self.user.words = [self.user.words stringByAppendingFormat:@"%@%@",WORD_SEPARATED,wordTerm];
        self.user.comsumeWordNum = [NSNumber numberWithInt:[self.user.comsumeWordNum intValue] + 1];
        [self.danciDatabase saveToURL:self.danciDatabase.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            NSLog(@"save data in scram.");
        }];
        NSLog(@"now user:[%@]", self.user);
//        NSError *error = nil;
//        [self.danciDatabase.managedObjectContext save:&error];
        return FALSE;
    }
}

- (void) reloadTipimgsForWord:(NSString *) wordTerm atBegin:(int) begin requestCount:(int) count
{
    dispatch_queue_t queueImg = dispatch_queue_create("downloadTipimg", NULL);
    dispatch_async(queueImg, ^{
        NSArray *tmpimgs = [DanciServer getWordTipsImg:wordTerm atBegin:begin requestCount:count];
        [self.tipImgs addObjectsFromArray:tmpimgs];
        //完成后通知tblimg更新
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tblTipimgsIphone reloadData];
            NSLog(@"query get [%d] imgs. now total img num[%d]", [tmpimgs count], [self.tipImgs count]);
        });
    });
}

- (void) reloadTipsentenceForWord:(NSString *)wordTerm
{
    dispatch_queue_t queueSentence = dispatch_queue_create("downloadSentence", NULL);
    dispatch_async(queueSentence, ^{
        NSArray *sentences = [DanciServer getWordTipsSentence:wordTerm];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tipSentences = sentences;
            //完成后 通知tblsentence更新
            [self.tblTipSentence reloadData];
            NSLog(@"query get [%d] sentence.", [self.tipSentences count]);
        });
    });
}

//从coredata中取出当前word的各种信息： 发音 真人发音mp3 中文释义 词根词缀 例句 例句mp3地址 从网络获取tipImgs tipTxts 例句mp3
- (void) getWordInfo
{
    self.word = [Word getWord:self.wordTerm inManagedObjectContext:self.danciDatabase.managedObjectContext];
    NSLog(@"get word:[%@] word term[%@]", self.word, self.word.word);
    //清楚上一个单词的数据
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
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self.tblTipSentence setDelegate:self];
    [self.tblTipSentence setDataSource:self];
    
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
//    backItem.title = @"<";
//    self.navigationItem.leftBarButtonItem = backItem;
//    [self.navigationItem.leftBarButtonItem setTitle:@"x"];

    [self drawMyView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) playWordMp3
{
    NSLog(@"navigation title click. play word mp3[%@]",self.fayinMp3Url);
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
//                NSLog(@"play successed. mp3url[%@]", self.fayinMp3Url);
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
    _btnCover.frame = CGRectMake(0, 0, 320, 620);
    [self.navigationItem.titleView removeFromSuperview];
    [_btnCover setTitle:[self.msgReview stringByAppendingFormat:@"%@ 是什么意思？", self.wordTerm] forState:UIControlStateNormal];
    [_btnCover setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _btnCover.backgroundColor = [UIColor whiteColor];
    [_btnCover addTarget:self action:@selector(drawMyViewReal:) forControlEvents:UIControlEventTouchUpInside];
    _btnCover.tintColor = [UIColor whiteColor];
    
    [self.view addSubview:_btnCover];
}

- (void) printFrame:(CGRect)frame
{
    NSLog(@"x[%f] y[%f] width[%f] height[%f]",frame.origin.x, frame.origin.y, frame.size.width,frame.size.height);
}

- (void) showExpandTipinfo
{
    //hidder the imgtableview
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    
    [self.tblTipimgsIphone.layer addAnimation:animation forKey:nil];
    self.constrainsTipimgsHeight.constant = 0.1f;
    self.tblTipimgsIphone.hidden = TRUE;
    
    [UIView commitAnimations];
}

- (void) showNormalTipinfo
{
    //hidder the imgtableview
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    
    [self.tblTipimgsIphone.layer addAnimation:animation forKey:nil];
    self.constrainsTipimgsHeight.constant = 100.0f;
    self.tblTipimgsIphone.hidden = FALSE;
    
    [UIView commitAnimations];
}

- (void)drawMyViewReal:(UIButton *)sender {
    [sender removeFromSuperview];
    
    [self showExpandTipinfo];
    
    //title显示当前正在学习或复习的单词
    self.title = @"主界面";
    NSString *title = [[self.word.word stringByAppendingString:@" "] stringByAppendingString:self.word.yin_biao];
    UIButton *btnTitle = [[UIButton alloc] init];
    [btnTitle setTitle:title forState:UIControlStateNormal];
    [btnTitle addTarget:self
                 action:@selector(playWordMp3)
       forControlEvents:UIControlEventTouchDown];
    [btnTitle setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.navigationItem setTitleView:btnTitle];
    
    self.lblMeaning.text = self.word.meaning;
    self.lbltips.text = self.tips;
    self.lbltips.font = self.fontDetail;
    
    //读图片
    NSLog(@"load filepath[%@]", self.tipImgFilepath);
    NSFileManager *filemanager = [NSFileManager defaultManager];
    self.btnTipImgIphone.imageView.contentMode = UIViewContentModeScaleAspectFit;
    if([filemanager fileExistsAtPath: self.tipImgFilepath]){
        NSData *imagedata = [NSData dataWithContentsOfFile:self.tipImgFilepath];
        UIImage *wordImg = [UIImage imageWithData:imagedata];
        [self.btnTipImgIphone setBackgroundImage:nil forState:UIControlStateNormal];
        [self.btnTipImgIphone setImage:wordImg forState:UIControlStateNormal];
    }else{
        [self.btnTipImgIphone setImage:nil forState:UIControlStateNormal];
        [self.btnTipImgIphone setBackgroundImage:self.defaultTipImg forState:UIControlStateNormal];
    }
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
        [segue.destinationViewController setCurWord:self.word];
        [segue.destinationViewController setCurUser:self.user];
        [segue.destinationViewController setDelegate:self];
        [segue.destinationViewController setDanciDatabase:self.danciDatabase];
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
//        NSLog(@"load tip imgs in tblTipimgsIphone. img count[%d]",[self.tipImgs count]);
        static NSString *CellIdentifier = CELL_ID_TIPIMG;
        PPImageScrollingTableViewCell *customCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        NSArray *cellData = self.tipImgs;
        [customCell setBackgroundColor:[UIColor grayColor]];
        [customCell setDelegate:self];
        [customCell setImageData:cellData];
        [customCell setCollectionViewBackgroundColor:[UIColor darkGrayColor]];
        return customCell;
    }else if(tableView == self.tblTipSentence){
//        NSLog(@"load data for tblTipSentence at row[%d]", indexPath.row);
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
    if(self.user.mid == nil || [self.user.mid length] < 2){
        [self popLoginView:TYPE_LOGIN];
        return;
    }
    if([self.user.maxWordNum intValue] - [self.user.comsumeWordNum intValue] < 1){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"充值提醒" message:@"亲，学习上限耗尽，请到充值后到设置刷新帐户吧:)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    NSString *imgName = [[self.tipImgs objectAtIndex:indexPathOfImage.row]objectForKey:TIPS_IMG_NAME];
    NSString *imgUrl = [[self.tipImgs objectAtIndex:indexPathOfImage.row] objectForKey:TIPS_IMG_URL];
    NSString *imgKey = [[self.tipImgs objectAtIndex:indexPathOfImage.row] objectForKey:TIPS_IMG_KEY];
    PPCollectionViewCell *cell = (PPCollectionViewCell *) [sender.imageScrollingView.myCollectionView cellForItemAtIndexPath:indexPathOfImage];
    NSData *imgData = UIImageJPEGRepresentation(cell.imageView.image, 0.0f);
    UIImage *img = [UIImage imageWithData:imgData];
    [self.btnTipImgIphone setBackgroundImage:nil forState:UIControlStateNormal];
    [self.btnTipImgIphone setImage:img forState:UIControlStateNormal];
    NSLog(@"selected img info: imgName:[%@] imgUrl:[%@]", imgName, imgUrl);
    
    //图片保存到本地
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileName = [[[paths objectAtIndex:0] stringByAppendingString:@"/" ] stringByAppendingString:self.word.word];
    if([imgData length] > 0 && [imgData writeToFile:fileName atomically:YES]){
        NSLog(@"write img ok. word[%@] filename[%@]", self.wordTerm, fileName);
    }else{
        NSLog(@"write img failed! word[%@] filename[%@]", self.wordTerm, fileName);
    }
    
    //将采纳发送到server
    NSDictionary *postData = @{@"studyNo":self.user.studyNo,
                               @"word":self.word.word,
                               @"otype":[NSNumber numberWithInt:StudyOperationTypeSeletTipImg],
                               @"ovalue":imgKey,
                               @"opt_time":[NSDate date],
                               };
    dispatch_queue_t queue = dispatch_queue_create("postImgSel", NULL);
    dispatch_async(queue, ^{
        if(![DanciServer postStudyOperation:postData] == ServerFeedbackTypeOk){
            NSLog(@"post img select study operation data to Server failed. save it to DB");
        }else{
            NSLog(@"post img select study operation data to Server OK.");
        }
    });
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

- (void)pushDataToUser:(NSDictionary *)userInfo
{
    self.user.mid = [userInfo objectForKey:@"mid"];
    self.user.studyNo = [NSNumber numberWithInt:[[userInfo objectForKey:@"studyNo"] intValue]];
    self.user.maxWordNum = [NSNumber numberWithInt:[[userInfo objectForKey:@"maxWordNum"] intValue]];
    self.user.comsumeWordNum = [NSNumber numberWithInt:[[userInfo objectForKey:@"comsumeWordNum"]intValue]];
    self.user.regTime = [NSDate dateWithTimeIntervalSince1970:[[userInfo objectForKey:@"regTime"] intValue]];
    [self.danciDatabase saveToURL:self.danciDatabase.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
        NSLog(@"push data to user ok");
    }];
}

-(void) popoverListViewLogin:(UIPopoverListView *)popoverListView oldUser:(NSDictionary *)userInfo
{
    [self pushDataToUser:userInfo];
    NSLog(@"user login in. user:%@", self.user);
}

-(void) popoverListViewRegist:(UIPopoverListView *)popoverListView newUser:(NSDictionary *)userInfo
{
    [self pushDataToUser:userInfo];
    NSLog(@"user regist. user:%@", self.user);
}

#pragma mark - DanciEditTipTxtDelegate

-(void) eidtTipTxt:(DanciEditTipTxtViewController *)sender didEditTipTxtOk:(NSDictionary *)callbackdata operationType:(StudyOperationType)otype
{
    if(otype == StudyOperationTypeNone){
        return;
    }
    //设置view的相关控件
    self.lbltips.text = self.tips;
    
    //将采纳发送到server
    dispatch_queue_t queue = dispatch_queue_create("postTiptxtSel", NULL);
    dispatch_async(queue, ^{
        if(![DanciServer postStudyOperation:callbackdata] == ServerFeedbackTypeOk){
            //发送失败则写入本地 -- 第一版只保存单词信息反馈
//            [StudyOperation saveStudyOperationWithInfoAfterUploadFailed:callbackdata inManagedObjectContext:self.danciDatabase.managedObjectContext];
            NSLog(@"post study tiptxt select operation data to Server failed. save it to DB");
        }else{
            NSLog(@"post study tiptxt select operation data to Server OK.");
        }
    });
}

#pragma mark - videoplaydelegate

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"播放完毕 %d",flag);
}

#pragma mark - event hander

- (IBAction)showImgTips:(id)sender {
    //show the tbl
    if(self.tblTipimgsIphone.hidden){
        [self showNormalTipinfo];
    }else{
        [self showExpandTipinfo];
    }
}

- (IBAction)showTipstxt:(id)sender {
    //判断是否登陆
    NSLog(@"user [%@]", self.user);
    if(self.user.mid == nil || [self.user.mid length] < 2){
        [self popLoginView:TYPE_LOGIN];
        return;
    }
    if([self.user.maxWordNum intValue] - [self.user.comsumeWordNum intValue] < 1){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"充值提醒" message:@"亲，学习上限使用完毕，请到设置界面充值吧。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [self performSegueWithIdentifier:SEGUE_EDIT sender:self];
}

- (IBAction)showNextWord:(id)sender {
    //用户的帐户消耗
    int wordStudyFlag = studyOperationFlagWordReview;
    if(![self isWordStudiedOtherwiseAdd:self.wordTerm] && self.counter != NUM_LEANING_GROUP){
        self.counter += 1;
        wordStudyFlag = studyOperationFlagWordNewStudy;
    }
    NSLog(@"user maxWordNum[%d] comsumeWordNum[%d]",[self.user.maxWordNum intValue], [self.user.comsumeWordNum intValue]);
    if([self.user.maxWordNum intValue] > 0 && [self.user.maxWordNum intValue] - [self.user.comsumeWordNum intValue] < 1){
        dispatch_queue_t que = dispatch_queue_create("merger user", NULL);
        dispatch_async(que, ^{
            self.user = [UserInfo mergerUserWithServer:self.danciDatabase.managedObjectContext];
        });
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"充值提醒" message:@"亲，学习上限耗尽，请到充值后到设置刷新帐户吧:)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    //5+-2及时复习策略的数据队列的更新
    int feedback = StudyOperationTypeFeedbackOk;
    if(sender == self.btnFeedbackOk){
        //把该word从不认识和模糊队列删除
        [self.reviewNo removeObject:self.wordTerm];
        [self.reviewFuzze removeObject:self.wordTerm];
    }else if(sender == self.btnFeedbackFuzz){
        feedback = StudyOperationTypeFeedbackFuzzy;
        if(![self.reviewFuzze containsObject:self.wordTerm]){
            [self.reviewFuzze addObject:self.wordTerm];
        }
    }else if(sender == self.btnFeedbackNo){
        feedback = StudyOperationTypeFeedbackNagative;
        if(![self.reviewNo containsObject:self.wordTerm]){
            [self.reviewNo addObject:self.wordTerm];
        }
    }
    
    //反馈发送到server
    dispatch_queue_t queue = dispatch_queue_create("postWordFeedback", NULL);
    dispatch_async(queue, ^{
        NSDictionary *postData = @{@"studyNo":self.user.studyNo,
                                   @"word":self.wordTerm,
                                   @"otype":[NSNumber numberWithInt:feedback],
                                   @"ovalue":[@"" stringByAppendingFormat:@"%d",feedback],
                                   @"opt_time":[NSDate date],
                                   @"flag":[NSNumber numberWithInt:wordStudyFlag]};
        [StudyOperation saveStudyOperationWithInfoAfterUploadFailed:postData inManagedObjectContext:self.danciDatabase.managedObjectContext];
        if(![DanciServer postStudyOperation:postData] == ServerFeedbackTypeOk){
            NSLog(@"post img select study operation data to Server failed. save it to DB");
        }else{
            NSLog(@"post img select study operation data to Server OK.");
        }
    });
    
    //判断从及时复习队列取还是从单词本取
    //未掌握单词超过了3个、模糊单词数超过5个、单词本学习完成了、学习了20个新单词了
    if([self.reviewNo count] >= NUM_NEED_REVIEW_FUZZLE || [self.reviewFuzze count] >= NUM_NEED_REVIEW_NO || ([self.reviewNo count] + [self.reviewFuzze count]) >= NUM_NEED_REVIEW_NOANDFUZZLE || self.counter == NUM_LEANING_GROUP || [self.album.point intValue] % [self.album.count intValue] == 0){
        self.msgReview = @"复习:";
        if([self.reviewNo count] > 0){
            self.wordTerm = [self.reviewNo objectAtIndex:0];
            [self.reviewNo removeObjectAtIndex:0];
            [self.reviewFuzze addObject:self.wordTerm];
            [self drawMyView];
            return;
        }else if ([self.reviewFuzze count] > 0){
            self.wordTerm = [self.reviewFuzze objectAtIndex:0];
            [self.reviewFuzze removeObjectAtIndex:0];
            [self drawMyView];
            return;
        }
    }
    self.msgReview = @"";
    if(self.counter == NUM_LEANING_GROUP){
        self.counter = 0;
    }
    
    //取下一个单词，redraw view
    int curPoint = ([self.album.point intValue] - 1) % [self.album.count intValue] + 1;
    self.album.point = [NSNumber numberWithInt:([self.album.point intValue] + 1)];
    NSLog(@"reflush .. now wordPoint[%d] album length[%d]", [self.album.point intValue], [self.words count]);
    if(curPoint != [self.words count]){
        self.wordTerm = [self.words objectAtIndex:curPoint];
        [self.view setNeedsDisplay];
        [self drawMyView];
    }else{
        NSString *msg = [@"" stringByAppendingFormat:@"赞！同学，你学完了[%@]！真棒！我们去挑战新的吧:)", self.album.name];
        //vip 7777 答应阿眠同学的惊喜
        if([self.user.studyNo intValue] == 7777){
            msg = [@"" stringByAppendingFormat:@"赞！阿眠MM，你学完了[%@]！btw：谢谢你的糖果哦，如果能吃到就更好了。我们去挑战新的吧:)", self.album.name];
        }
        if([self.album.name isEqualToString:ALBUM_NAME_REVIEW]){
            msg = @"赞！复习完成！在遗忘零界点复习绝对的事半半、功倍倍！继续学习吧 :)";
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"学成!" message:msg delegate:self cancelButtonTitle:@"OK 走起！" otherButtonTitles:nil];
        [alertView show];
        [self.danciDatabase saveToURL:self.danciDatabase.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            NSLog(@"save all data to coredata after kill an album.");
        }];
    }
}

#pragma mark UIActionSheetDelegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
    if([self.album.name isEqualToString:ALBUM_NAME_REVIEW]){
        self.album.count = [NSNumber numberWithInt:0];
        self.album.point = [NSNumber numberWithInt:1];
        NSLog(@"now the review album can go out of the albums.[%@]",self.album.count);
    }
}

@end

