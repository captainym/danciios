//
//  DanciWordViewController.m
//  Danci
//
//  Created by HuHao on 13-9-20.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import "DanciWordViewController.h"
#import "PPImageScrollingTableViewCell.h"

//图片的tableView需要150的宽度。ipad下可以考虑更大
#define HEIGHT_IMG_ROW 100.0

@interface DanciWordViewController () <PPImageScrollingTableViewCellDelegate, UITableViewDataSource,UITableViewDelegate,AVAudioPlayerDelegate,TQTableViewDataSource, TQTableViewDelegate>

@end

@implementation DanciWordViewController

//properties synthesize
@synthesize isNewStudy = _isNewStudy;
@synthesize isReview = _isReview;

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
    _wordPoint = wordPoint - 1;
}
- (NSString *) word
{
    if(![_word isEqualToString: [self.words objectAtIndex:self.wordPoint]]){
        NSLog(@"word not equal. load again. _word[%@] new word[%@]", _word,[self.words objectAtIndex:self.wordPoint]);
        _word = [self.words objectAtIndex:self.wordPoint];
        [self getWordInfo];
    }
    return _word;
}
- (NSString *) wordGern
{
    return _wordGern;
}

//从coredata中取出当前word的各种信息： 发音 真人发音mp3 中文释义 词根词缀 例句 例句mp3地址 从网络获取tipImgs tipTxts 例句mp3
- (void) getWordInfo
{
    //先用假数据
    _word = @"psychology";
    self.fayin = @"[saɪˈkɒlədʒɪ]";
    self.comment = @"n.【心】心理学；心理特征；〈非正式〉【心】看穿别人心理的能力";
    self.fayinMp3Url = @"wordmp3/p/psychology.arm";
    self.tipImgFilepath = @"psychology_md51.jpeg";
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
    [self.tipTxts addObjectsFromArray: @[
     @{@"tip":@"log=science,表示\"科学,学科\"。psychology n 心理学（paych 心理+o+log+y)", @"adoptNum": @"271" , @"optTime":@"18000" },
     @{@"tip":@"PSY鸟叔，心理变态", @"adoptNum": @"93" , @"optTime":@"18000" },
     @{@"tip":@"各种常见的学 psychology 心理学 chemistry 化学 physics 物理学 mathematics 数学 literature 文学 astronomy 天文学", @"adoptNum": @"48" , @"optTime":@"18000" },
     @{@"tip":@"psych=mind, logy=某种学问，关于mind的学问，心理学", @"adoptNum": @"28" , @"optTime":@"18000" },
     ]];
    [self.tipSentences addObjectsFromArray:@[
     @{@"sentence":@"It seems to me that the psychology is abundantly clear.", @"mp3":@"http://dbl-rdtest-3-04.vm.baidu.com:8090/psychology.mp3"},
     @{@"sentence":@"It seems to me that the psychology is abundantly clear.", @"mp3":@"http://media.engkoo.com:8129/en-us/2CC9D118D62C36D1CBF69744F3BC85F9.mp3"},
     ]];
    NSLog(@"tipImg count%d ", [self.tipImgs count]);
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //title显示当前正在学习或复习的单词
    self.title = [[self.word stringByAppendingString:@" "] stringByAppendingString:self.fayin];
    self.lblMeaning.text = self.comment;
    self.lblStem.text= self.wordGern;
    self.lblMeaningStemIphone.text = [@"简明释义：" stringByAppendingString:[[self.comment stringByAppendingString:@"\n词根词缀："] stringByAppendingString:self.wordGern]];
    self.lblMeaningStemIphone.adjustsFontSizeToFitWidth = TRUE;
    //读图片
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                       , NSUserDomainMask
                                                       , YES);
    NSString *filepath = [[paths objectAtIndex:0] stringByAppendingPathComponent:self.word];
    NSLog(@"load filepath[%@]", filepath);
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if([filemanager fileExistsAtPath: filepath]){
        NSData *imagedata = [NSData dataWithContentsOfFile:filepath];
        self.imgTipimg.image = [UIImage imageWithData:imagedata];
        self.imgTipimgIphone.image = [UIImage imageWithData:imagedata];
    }
    
    //注册cell
    static NSString *CellIdentifier = cellTipimg;
    [self.tblTipimgs registerClass:[PPImageScrollingTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    [self.tblTipimgs setDataSource:self];
    [self.tblTipimgs setDelegate:self];
    
    //iphone
    [self.tblTipimgsIphone registerClass:[PPImageScrollingTableViewCell class] forCellReuseIdentifier:cellTipimg];
    [self.tblTipimgsIphone setDelegate:self];
    [self.tblTipimgsIphone setDataSource:self];
    
    //iphone－tip sentence 的multisagetableview
//    CGRect mFrame = CGRectMake(self.svTiptxtsentence.frame.origin.x, self.svTiptxtsentence.frame.origin.y, self.svTiptxtsentence.frame.size.width, self.svTiptxtsentence.frame.size.height - 1);
    CGRect mFrame = CGRectMake(0.0, 0.0, 314.0, 230.0);
    self.tblMultipsIphone = [[TQMultistageTableView alloc] initWithFrame: mFrame];
    self.tblMultipsIphone.delegate = self;
    self.tblMultipsIphone.dataSource = self;
    [self.vtip addSubview:self.tblMultipsIphone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == self.tblTipimgs || tableView == self.tblTipimgsIphone){
        return 1;
    }else if (tableView == self.tblTiptxt){
        return 1;
    }else if(tableView == self.tblTipsentense){
        return 1;
    }else{
        NSLog(@"DANCI WARNING: see sections. tableview is Nagative! tableViewId[%@]", tableView.restorationIdentifier);
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.tblTipimgs || tableView == self.tblTipimgsIphone){
        return 1;
    }else if (tableView == self.tblTiptxt){
        NSLog(@"now number of rows of tblTiptxt:[%d]", [self.tipTxts count]);
        return [self.tipTxts count];
    }else if(tableView == self.tblTipsentense){
        NSLog(@"now number of rows of tblSentence:[%d]", [self.tipSentences count]);
        return [self.tipSentences count];
    }else{
        NSLog(@"DANCI WARNING: see sections. tableview is Nagative! tableViewId[%@]", tableView.restorationIdentifier);
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if(tableView == self.tblTipimgs || tableView == self.tblTipimgsIphone){
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
    }else if (tableView == self.tblTiptxt){
        //显示txt tip
        cell = [tableView dequeueReusableCellWithIdentifier:cellTiptxt forIndexPath:indexPath];
        cell.textLabel.text = [[self.tipTxts objectAtIndex:[indexPath row]] objectForKey:@"tip"];
    }else if (tableView == self.tblTipsentense){
        //显示txt tip
        cell = [tableView dequeueReusableCellWithIdentifier:cellTipsentence forIndexPath:indexPath];
        cell.textLabel.text = [[self.tipSentences objectAtIndex:[indexPath row]] objectForKey:@"sentence"]; 
    }else{
        NSLog(@"DANCI WARNING: loading cell. tableview is Nagative! tableViewId[%@]", tableView.restorationIdentifier);
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tblTipsentense){
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

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"播放完毕 %d",flag);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //图片的tableView需要150的宽度。ipad下可以考虑更大。其他默认
    if(tableView == self.tblTipimgs || tableView == self.tblTipimgsIphone){
        return HEIGHT_IMG_ROW;
    }else{
        return 50.0f;
    }
}

#pragma mark - PPImageScrollingTableViewCellDelegate

//用户选择了一个图片之后
- (void)scrollingTableViewCell:(PPImageScrollingTableViewCell *)sender didSelectImageAtIndexPath:(NSIndexPath*)indexPathOfImage
{
    NSString *imgName = [[self.tipImgs objectAtIndex:indexPathOfImage.row]objectForKey:@"name"];
    NSString *imgUrl = [[self.tipImgs objectAtIndex:indexPathOfImage.row] objectForKey:@"url"];
    NSLog(@"selected img info: imgName:[%@] imgUrl:[%@]", imgName, imgUrl);
    dispatch_queue_t downloadImg = dispatch_queue_create("downloadImg", NULL);
    dispatch_async(downloadImg, ^{
        NSURL *imgUrlNet = [NSURL URLWithString:imgUrl];
        NSData * imgData = [NSData dataWithContentsOfURL:imgUrlNet];
        dispatch_async(dispatch_get_main_queue(),^{
            UIImage *img = [UIImage imageWithData:imgData];
            self.imgTipimg.image = img;
            self.imgTipimgIphone.image = img;
        });
        
        //图片保存到本地
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *fileName = [[[paths objectAtIndex:0] stringByAppendingString:@"/" ] stringByAppendingString:self.word];
        if([imgData writeToFile:fileName atomically:YES]){
            NSLog(@"write img ok. word[%@] filename[%@]", self.word, fileName);
        }else{
            NSLog(@"write img failed! word[%@] filename[%@]", self.word, fileName);
        }
    });
    
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
    
    //加载tips
    if(indexPath.section == 0){
        cell.textLabel.text = [[self.tipTxts objectAtIndex:indexPath.row] objectForKey:@"tip"];
    }else{
    //加载sentence
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
        return HEIGHT_TIP_TXT;
    }else{
        return HEIGHT_SENTENCE;
    }
}

- (CGFloat)mTableView:(TQMultistageTableView *)tableView heightForOpenCellAtIndexPath:(NSIndexPath *)indexPath
{
    return HEIGHT_TQ_CELL;
}

- (UIView *)mTableView:(TQMultistageTableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * control = [[UIView alloc] init];
    control.backgroundColor = [UIColor whiteColor];
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor blackColor];
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor blackColor];
    UILabel *labelPin = [[UILabel alloc] init];
    labelPin.text = @">";
    labelPin.textColor = [UIColor greenColor];
    if(section == 0){
        if([self.tipTxt length] > 1){
            label.text = [@"助记：" stringByAppendingString: self.tipTxt];
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.numberOfLines = 0;
            label.frame = CGRectMake(20, 0, tableView.frame.size.width, HEIGHT_TIP_TXT - 2);
            view.frame = CGRectMake(0, HEIGHT_TIP_TXT - 2, tableView.frame.size.width,2);
            labelPin.frame = CGRectMake(0, 0, 20, HEIGHT_TIP_TXT - 2);
        }else{
            label.text = @"采纳助记";
            label.frame = CGRectMake(20, 0, 200, HEIGHT_SENTENCE - 2);
            view.frame = CGRectMake(0, HEIGHT_SENTENCE - 2, tableView.frame.size.width,2);
            labelPin.frame = CGRectMake(0, 0, 20, HEIGHT_TIP_TXT - 2);
        }
    }else{
        label.text = @"例句";
        label.frame = CGRectMake(20, 0, 200, HEIGHT_SENTENCE - 2);
        view.frame = CGRectMake(0, HEIGHT_SENTENCE - 2, tableView.frame.size.width,2);
        labelPin.frame = CGRectMake(0, 0, 20, HEIGHT_SENTENCE - 2);
    }
    [control addSubview:labelPin];
    [control addSubview:label];
    [control addSubview:view];
    return control;
}

- (void)mTableView:(TQMultistageTableView *)tableView didSelectHeaderAtSection:(NSInteger)section
{
    NSLog(@"headerClick%d",section);
}

//celll点击
- (void)mTableView:(TQMultistageTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellClick%@",indexPath);
}

//header展开
- (void)mTableView:(TQMultistageTableView *)tableView willOpenHeaderAtSection:(NSInteger)section
{
    NSLog(@"headerOpen%d",section);
}

//header关闭
- (void)mTableView:(TQMultistageTableView *)tableView willCloseHeaderAtSection:(NSInteger)section
{
    NSLog(@"headerClose%d",section);
}

- (void)mTableView:(TQMultistageTableView *)tableView willOpenCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"OpenCell%@",indexPath);
}

- (void)mTableView:(TQMultistageTableView *)tableView willCloseCellAtIndexPath:(NSIndexPath *)indexPath;
{
    NSLog(@"CloseCell%@",indexPath);
}

@end

