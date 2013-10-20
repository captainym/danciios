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
#define HEIGHT_IMG_ROW 150.0

@interface DanciWordViewController () <PPImageScrollingTableViewCellDelegate, UITableViewDataSource,UITableViewDelegate>

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
    _word = [self.words objectAtIndex:self.wordPoint];
    [self getWordInfo];
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
    self.wordGern = @"psy=sci，是一个偏旁部首，是“知道”的意思；\n cho是一个偏旁部首，是“心”的意思； lo是一个偏旁部首，是“说”的意思； gy是一个偏旁部首，是“学”的意思，logy合起来是“学说”的意思。 \n psy-cho-logy连起来就是“知道心的学说”。";
//    self.tipImgs = @[
//                     @{ @"name":@"psychology_md51.jpeg", @"url":@"psychology_md51.jpeg"},
//                     @{ @"name":@"name-sample_2.jpeg", @"url":@"psychology_md52.jpg"},
//                     @{ @"name":@"name-sample_3.jpeg", @"url":@"psychology_md53.jpg"},
//                     @{ @"name":@"name-sample_4.jpeg", @"url":@"psychology_md54.jpg"},
//                     @{ @"name":@"name-sample_5.jpeg", @"url":@"psychology_md55.jpg"},
//                     @{ @"name":@"name-sample_2.jpeg", @"url":@"psychology_md56.png"},
//                     @{ @"name":@"name-sample_3.jpeg", @"url":@"psychology_md57.jpg"},
//                     @{ @"name":@"name-sample_4.jpeg", @"url":@"psychology_md58.gif"},
//                     @{ @"name":@"name-sample_5.jpeg", @"url":@"psychology_md59.jpg"},
//                     @{ @"name":@"name-sample_6.jpeg", @"url":@"psychology_md519.jpg"}
//                     ];
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
     @{@"tip":@"文字助记1", @"adoptNum": @"50" , @"optTime":@"18000" },
     @{@"tip":@"文字助记2", @"adoptNum": @"50" , @"optTime":@"18000" },
     ]];
    [self.tipSentences addObjectsFromArray:@[
     @{@"sentence":@"friend is so good", @"mp3":@"./xxx.mp3"},
     @{@"sentence":@"friend is so NICE", @"mp3":@"./xxx2.mp3"},
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
    }
    
    //注册cell
//    [self.tblTipimgs registerClass:[UITableViewCell class] forCellReuseIdentifier:cellTipimg];
    static NSString *CellIdentifier = cellTipimg;
    [self.tblTipimgs registerClass:[PPImageScrollingTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    [self.tblTiptxt registerClass:[UITableViewCell class] forCellReuseIdentifier:cellTiptxt];
    [self.tblTipsentense registerClass:[UITableViewCell class] forCellReuseIdentifier:cellTipsentence];
    
    [self.tblTipimgs setDataSource:self];
    [self.tblTipimgs setDelegate:self];
    [self.tblTiptxt setDataSource:self];
    [self.tblTipsentense setDataSource:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == self.tblTipimgs){
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
    if(tableView == self.tblTipimgs){
        return 1;
    }else if (tableView == self.tblTiptxt){
        return [self.tipTxts count];
    }else if(tableView == self.tblTipsentense){
        return [self.tipSentences count];
    }else{
        NSLog(@"DANCI WARNING: see sections. tableview is Nagative! tableViewId[%@]", tableView.restorationIdentifier);
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if(tableView == self.tblTipimgs){
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
        cell.textLabel.text = @"tiptxt";
    }else if (tableView == self.tblTipsentense){
        //显示txt tip
        cell = [tableView dequeueReusableCellWithIdentifier:cellTipsentence forIndexPath:indexPath];
        cell.textLabel.text = @"tipsentence";
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
    if(tableView == self.tblTipimgs){
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
    NSData *imgdata = [NSData dataWithContentsOfURL: [NSURL URLWithString:imgUrl]];
    self.imgTipimg.image = [UIImage imageWithData:imgdata];
    
    //图片保存到本地
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                       , NSUserDomainMask
                                                       , YES);
    NSLog(@"Get document path: %@",[paths objectAtIndex:0]);
    
    NSString *fileName=[[paths objectAtIndex:0] stringByAppendingPathComponent:self.word];
    NSLog(@"fileName:[%@]", fileName);
    if ([imgdata writeToFile:fileName atomically:YES]) {
        NSLog(@">>write ok.");
    }
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat: @"Image %@",imgName]
    //                                                    message:[NSString stringWithFormat: @"in %@",imgUrl]
    //                                                   delegate:self
    //                                          cancelButtonTitle:@"OK"
    //                                          otherButtonTitles: nil];
//    [alert show];
}


@end
