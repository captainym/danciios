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
    self.comment = @"朋友";
    self.wordGern = @"词根词缀";
    self.tipImgs = @[
                     @{ @"name":@"sample_1.jpeg", @"url":@"A-0"},
                     @{ @"name":@"sample_2.jpeg", @"url":@"A-1"},
                     @{ @"name":@"sample_3.jpeg", @"url":@"A-2"},
                     @{ @"name":@"sample_4.jpeg", @"url":@"A-3"},
                     @{ @"name":@"sample_5.jpeg", @"url":@"A-4"},
                     @{ @"name":@"sample_6.jpeg", @"url":@"A-5"}
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
    self.title = self.word;
    self.lblMeaning.text = self.comment;
    self.lblStem.text= self.wordGern;
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
    }else if (tableView == self.tblTiptxtSentense){
        return 2;
    }else{
        NSLog(@"DANCI WARNING: see sections. tableview is Nagative! tableViewId[%@]", tableView.restorationIdentifier);
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.tblTipimgs){
        return 1;
    }else if (tableView == self.tblTiptxtSentense){
        if(section == 1){
            return [self.tipTxts count];
        }else if(section == 2){
            return [self.tipSentences count];
        }else{
            return 0;
        }
    }else{
        NSLog(@"DANCI WARNING: see sections. tableview is Nagative! tableViewId[%@]", tableView.restorationIdentifier);
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    
    /*
    if(tableView == self.tblTipImgs){
        /
        static NSString *CellIdentifier = @"CellTipImg";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
         /
        
        //显示图片
        static NSString *CellIdentifier = @"CellTipImg";
        PPImageScrollingTableViewCell *customCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        NSArray *cellData = self.tipImgs;
        [customCell setBackgroundColor:[UIColor grayColor]];
        [customCell setDelegate:self];
        [customCell setImageData:cellData];
        //[customCell setCategoryLabelText:[cellData objectForKey:@"category"] withColor:[UIColor whiteColor]];
        [customCell setTag:[indexPath section]];
        //[customCell setImageTitleTextColor:[UIColor whiteColor] withBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
        //[customCell setImageTitleLabelWitdh:90 withHeight:45];
        [customCell setCollectionViewBackgroundColor:[UIColor darkGrayColor]];
         
    }else if (tableView == self.tblTipTxts){
        static NSString *CellIdentifier = @"CellTipTxt";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        //显示txt tip¬
    }else if (tableView == self.tblTipSentens){
        static NSString *CellIdentifier = @"CellTipSentence";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        //显示例句
    }else{
        NSLog(@"DANCI WARNING: loading cell. tableview is Nagative! tableViewId[%@]", tableView.restorationIdentifier);
    }
*/
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    if(tableView == self.tblTipImgs){
    }else if (tableView == self.tblTipTxts){
    }else if (tableView == self.tblTipSentens){
    }else{
        NSLog(@"DANCI WARNING: didSelected. tableview is Nagative! tableViewId[%@]", tableView.restorationIdentifier);
    }
     */
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
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat: @"Image %@",imgName]
                                                    message:[NSString stringWithFormat: @"in %@",imgUrl]
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}


@end
