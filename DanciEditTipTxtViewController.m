//
//  DanciEditTipTxtViewController.m
//  Danci
//
//  Created by ShiYuming on 13-11-16.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import "DanciEditTipTxtViewController.h"
#import <QuartzCore/QuartzCore.h>

#define CELL_ID_TIPS_TXT @"cellTipstxt"
#define DEFAULT_REQUEST_COUNT_TIPS 10

@interface DanciEditTipTxtViewController () <UITextViewDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *tipstxt;

//界面初始化
- (void) initScrollView;

//控制显示哪种界面
- (void) showView;

//显示采纳tips的界面
- (void) showAdopTipsView;

//显示编辑tips的界面
- (void) showEditTipsView;

//创建空界面
- (void) createEmptyPagesForScrollView;

@end

@implementation DanciEditTipTxtViewController

@synthesize delegate = _delegate;
@synthesize danciDatabase = _danciDatabase;
@synthesize curWord = _curWord;
@synthesize tipstxt = _tipstxt;
@synthesize curUser = _curUser;

-(NSMutableArray *) tipstxt
{
    if(_tipstxt == nil){
        _tipstxt = [[NSMutableArray alloc] init];
    }
    return _tipstxt;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    dispatch_queue_t queue = dispatch_queue_create("downloadtips", NULL);
    dispatch_async(queue, ^{
        NSArray *getTips = [DanciServer getWordTipsTxt:self.curWord.word atBegin:0 requestCount:DEFAULT_REQUEST_COUNT_TIPS];
        [self.tipstxt addObjectsFromArray:getTips];
        NSLog(@"request get tips num[%d]", [getTips count]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [tblTipstxt reloadData];
        });
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = self.curWord.word;

    //控件初始化
    self.btnAdopTip.showsTouchWhenHighlighted = YES;
    [self.btnAdopTip setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnAdopTip addTarget:self action:@selector(showAdopTipsView) forControlEvents:UIControlEventTouchUpInside];
    self.btnEditTip.showsTouchWhenHighlighted = YES;
    [self.btnEditTip setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnEditTip addTarget:self action:@selector(showEditTipsView) forControlEvents:UIControlEventTouchUpInside];
    
    [self initScrollView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - view

- (void) showView
{
    if(curPage == 0){
        [self showAdopTipsView];
    }else{
        [self showEditTipsView];
    }
}

- (void) showAdopTipsView
{
    [self.btnAdopTip setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnEditTip setTitleColor:[UIColor groupTableViewBackgroundColor] forState:UIControlStateNormal];
    
    [UIView beginAnimations:nil context:nil];//动画开始
    [UIView setAnimationDuration:0.3];
    
    float lbly = self.lblPink.frame.origin.y;
    self.lblPink.frame = CGRectMake(0, lbly, 160, 4);
    [self.mScrollView setContentOffset:CGPointMake(320*0, 0)];//页面滑动
    
    [UIView commitAnimations];
    [tblTipstxt reloadData];
}

- (void) showEditTipsView
{
    [self.btnEditTip setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnAdopTip setTitleColor:[UIColor groupTableViewBackgroundColor] forState:UIControlStateNormal];
    
    [UIView beginAnimations:nil context:nil];//动画开始
    [UIView setAnimationDuration:0.3];
    
    float lbly = self.lblPink.frame.origin.y;
    self.lblPink.frame = CGRectMake(162, lbly, 160, 4);
    [self.mScrollView setContentOffset:CGPointMake(320*1, 0)];//页面滑动
    
    [UIView commitAnimations];
}

#pragma mark - 滑动效果 视图切换

- (void)initScrollView
{
    //一个page是一个scollView
    self.mScrollView.pagingEnabled = YES;
    self.mScrollView.clipsToBounds = NO;
    self.mScrollView.contentSize = CGSizeMake(self.mScrollView.frame.size.width * 2, self.mScrollView.frame.size.height);
    self.mScrollView.showsHorizontalScrollIndicator = NO;
    self.mScrollView.showsVerticalScrollIndicator = NO;
    self.mScrollView.scrollsToTop = NO;
    self.mScrollView.delegate = self;
    [self.mScrollView setContentOffset:CGPointMake(0, 0)];
    
    self.lblPink.text = @"";
    curPage = 0;
    pageControl.numberOfPages = 2;
    pageControl.currentPage = curPage;
    pageControl.backgroundColor = [UIColor whiteColor];
    [self createEmptyPagesForScrollView];
    
}

- (void)createEmptyPagesForScrollView
{
    //设置page-选择助记
    tblTipstxt = [[UITableView alloc] init];
    tblTipstxt.frame = CGRectMake(320 * 0, 0, 320, self.mScrollView.frame.size.height);
    [tblTipstxt registerClass:[UITableViewCell class] forCellReuseIdentifier:CELL_ID_TIPS_TXT];
    [tblTipstxt setDelegate:self];
    [tblTipstxt setDataSource:self];
    [self.mScrollView addSubview:tblTipstxt];
    
    //设置page－编辑助记
    lbltip = [[UILabel alloc] init];
    lbltip.frame = CGRectMake(320 * 1, 0, 320, 45);
    lbltip.numberOfLines = 0;
    lbltip.text = [@"词根词缀:" stringByAppendingString:self.curWord.stem];
    lbltip.font = [UIFont fontWithName:@"Verdana" size:12];
    [self.mScrollView addSubview:lbltip];
    txtEditTip = [[UITextView alloc] init];
    txtEditTip.frame = CGRectMake(320 * 1, 50, 320, 100);
    txtEditTip.delegate = self;
    [txtEditTip setText:self.curWord.txt_tip];
    txtEditTip.layer.borderColor = [UIColor grayColor].CGColor;
    txtEditTip.layer.borderWidth = 0.5;
    txtEditTip.layer.cornerRadius = 5.0;
    [self.mScrollView addSubview:txtEditTip];
    btnOK = [[UIButton alloc] init];
    btnOK.frame = CGRectMake(320 * 1.2, 154, 320*0.6, 30);
    [btnOK setTitle:@"OK 这样就记住啦" forState:UIControlStateNormal];
    btnOK.backgroundColor = [UIColor darkGrayColor];
    btnOK.showsTouchWhenHighlighted = YES;
    [btnOK addTarget:self action:@selector(saveTipTxt:) forControlEvents:UIControlEventTouchUpInside];
    [self.mScrollView addSubview:btnOK];
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGFloat pageWidth = self.mScrollView.frame.size.width;
    int page = floor((self.mScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    pageControl.currentPage = page;
    curPage = page;
    pageControlUsed = NO;
    [self showView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //暂不处理 - 其实左右滑动还有包含开始等等操作
}

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    return YES;
}
- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return NO;
}

#pragma mark - UTTableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *tip = [[self.tipstxt objectAtIndex:indexPath.row] objectForKey:TIPS_TXT_TIP];
    self.curWord.txt_tip = tip;
    NSString *tipId = [[self.tipstxt objectAtIndex:indexPath.row] objectForKey:TIPS_TXT_ID];
    [self saveTipTxt:tipId forOperationType:StudyOperationTypeSelectTipTxt];
}

#pragma mark - UITableViewDataSource
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tipstxt count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_TIPS_TXT];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont fontWithName:@"Verdana" size:12];
    NSString * atip = [[self.tipstxt objectAtIndex:indexPath.row] objectForKey:TIPS_TXT_TIP];
    cell.textLabel.text = atip;
    return cell;
}

//保存编辑的文字助记
- (void)saveTipTxt:(NSString *)tip forOperationType:(StudyOperationType) otpye
{
    
    NSDictionary *retdata = @{@"studyNo":self.curUser.studyNo,
                              @"word":self.curWord.word,
                              @"otype":[NSNumber numberWithInt:otpye],
                              @"ovalue":tip,
                              @"opt_time":[NSDate date]};
    [self.delegate eidtTipTxt:self didEditTipTxtOk:retdata operationType:otpye];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)saveTipTxt:(UIButton *)sender {
    //验证是否合格
    NSString *editTip = txtEditTip.text;
    self.curWord.txt_tip = editTip;
    [self saveTipTxt:editTip forOperationType:StudyOperationTypeEditTip];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return TRUE;
}

#pragma mark - event handler

- (IBAction)showAdopt:(id)sender {
    [self showAdopTipsView];
}
- (IBAction)showTipsView:(id)sender {
    [self showEditTipsView];
}

@end
