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

@interface DanciWordViewController () <PPImageScrollingTableViewCellDelegate>

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

@synthesize tblTipImgs = _tblTipImgs;
@synthesize tblTipTxts = _tblTipTxts;
@synthesize tblTipSentens = _tblTipSentens;

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
    if(_words == nil) _words = [[NSArray alloc] init];
    return _words;
}
- (NSArray *) wordsReviewNow
{
    if(_wordsReviewNow == nil) _wordsReviewNow = [[NSArray alloc] init];
    return _wordsReviewNow;
}
- (NSMutableArray *) tipImgs
{
    if(_tipImgs == nil) _tipImgs = [[NSMutableArray alloc] init];
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
- (NSString *) word
{
    _word = [self.words objectAtIndex:self.wordPoint];
    return _word;
}

//从coredata中取出当前word的各种信息： 发音 真人发音mp3 中文释义 词根词缀 例句 例句mp3地址 从网络获取tipImgs tipTxts 例句mp3
- (void) getWordInfo
{
    //先用假数据
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //title显示当前正在学习或复习的单词
    self.title = self.word;
    
    //造些img的假数据
    NSDictionary *dict1 =[[NSDictionary alloc]
                          initWithObjects:@[@"sample_1.jpeg", @"sample_1.jpeg", nil] forKeys:@[@"name",@"url",nil] ];
    NSDictionary *dict2 =[[NSDictionary alloc]
                          initWithObjects:@[@"sample_2.jpeg", @"sample_2.jpeg", nil] forKeys:@[@"name",@"url",nil] ];
    NSDictionary *dict3 =[[NSDictionary alloc]
                          initWithObjects:@[@"sample_3.jpeg", @"sample_3.jpeg", nil] forKeys:@[@"name",@"url",nil] ];
    NSDictionary *dict4 =[[NSDictionary alloc]
                          initWithObjects:@[@"sample_4.jpeg", @"sample_4.jpeg", nil] forKeys:@[@"name",@"url",nil] ];
    NSDictionary *dict5 =[[NSDictionary alloc]
                          initWithObjects:@[@"sample_5.jpeg", @"sample_5.jpeg", nil] forKeys:@[@"name",@"url",nil] ];
    NSDictionary *dict6 =[[NSDictionary alloc]
                          initWithObjects:@[@"sample_6.jpeg", @"sample_6.jpeg", nil] forKeys:@[@"name",@"url",nil] ];
    [self.tipImgs addObject:dict1];
    [self.tipImgs addObject:dict2];
    [self.tipImgs addObject:dict3];
    [self.tipImgs addObject:dict4];
    [self.tipImgs addObject:dict5];
    [self.tipImgs addObject:dict6];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == self.tblTipImgs){
        return 1;
    }else if (tableView == self.tblTipTxts){
        return [self.tipTxts count];
    }else if (tableView == self.tblTipSentens){
        return [self.tipSentences count];
    }else{
        NSLog(@"DANCI WARNING: see sections. tableview is Nagative! tableViewId[%@]", tableView.restorationIdentifier);
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    // Configure the cell...
    
    if(tableView == self.tblTipImgs){
    }else if (tableView == self.tblTipTxts){
        static NSString *CellIdentifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }else if (tableView == self.tblTipSentens){
        static NSString *CellIdentifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }else{
        NSLog(@"DANCI WARNING: loading cell. tableview is Nagative! tableViewId[%@]", tableView.restorationIdentifier);
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tblTipImgs){
    }else if (tableView == self.tblTipTxts){
    }else if (tableView == self.tblTipSentens){
    }else{
        NSLog(@"DANCI WARNING: didSelected. tableview is Nagative! tableViewId[%@]", tableView.restorationIdentifier);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //图片的tableView需要150的宽度。ipad下可以考虑更大。其他默认
    if(tableView == self.tblTipImgs){
        return HEIGHT_IMG_ROW;
    }else{
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

#pragma mark - PPImageScrollingTableViewCellDelegate

//用户选择了一个图片之后
- (void)scrollingTableViewCell:(PPImageScrollingTableViewCell *)scrollingTableViewCell didSelectImageAtIndexPath:(NSIndexPath*)indexPathOfImage atCategoryRowIndex:(NSInteger)categoryRowIndex
{
    NSString *imgName = [[self.tipImgs objectAtIndex:[indexPathOfImage row]]objectForKey:@"name"];
    NSString *imgUrl = [[self.tipImgs objectAtIndex:categoryRowIndex] objectForKey:@"url"];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat: @"Image %@",imgName]
                                                    message:[NSString stringWithFormat: @"in %@",imgUrl]
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}


@end
