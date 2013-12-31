//
//  DanciAlbumTableViewController.m
//  Danci
//
//  Created by ShiYuming on 13-9-20.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import "DanciAlbumTableViewController.h"
#import "DanciWordViewController.h"
#import "Album+Server.h"
#import "Word+Server.h"
#import "UserInfo+Server.h"

#import "MYCustomPanel.h"
#import "MYBlurIntroductionView.h"


#define ALBUM_CATEGORY @"category"
#define ALBUM_LIST @"albums"
#define ALBUM_NAME @"albumName"
#define ALBUM_WORD_POINT @"wordPoint"
#define ALBUM_WORDS @"words"
#define ALBUM_CELL_ID @"theAlbum"
#define DATABASE_VERSION @"Danci1.0"
#define DATABASE_ALBUM_INIT_FILE @"album"
#define DATABASE_WORD_INIT_FILE @"words"

@interface DanciAlbumTableViewController () <MYIntroductionDelegate>

// 用户选中的album
@property (nonatomic, strong) Album *albumSelected;
@property (nonatomic, strong) Album *albumReview;

@end

@implementation DanciAlbumTableViewController

@synthesize danciDatabase = _danciDatabase;
@synthesize albumSelected = _albumSelected;
@synthesize albumReview = _albumReview;


// 初始化coredata的内容 第一次
-(void) dumpDataIntoDocument:(UIManagedDocument *)document
{
    dispatch_queue_t dumpQ = dispatch_queue_create("dump", NULL);
    dispatch_async(dumpQ, ^{
        //到主线程中操作 确保安全
        [document.managedObjectContext performBlock:^{
            NSString *fileAlbum = [[NSBundle mainBundle] pathForResource:DATABASE_ALBUM_INIT_FILE ofType:@"json"];
            NSLog(@"fileAlbum is [%@]", fileAlbum);
            [Album initStore:fileAlbum inManagedObjectContext:self.danciDatabase.managedObjectContext];
            
            NSString *fileWord  = [[NSBundle mainBundle] pathForResource:DATABASE_WORD_INIT_FILE ofType:@"json"];
            NSLog(@"fileWord is [%@]", fileWord);
            [Word initStore:fileWord inManagedObjectContext:self.danciDatabase.managedObjectContext];
            
            //显示地save
            [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
            //提取待复习的album
            self.albumReview = [Album getReviewAlbum:self.danciDatabase.managedObjectContext];
            NSLog(@"generate albumReview:%@",self.albumReview);
        }];
    });
}

//设置查询album
-(void) setupFetchedResultsController
{
    //配置section、查询内容（不要把words列表搞出来了）
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Album"];
    request.predicate = [NSPredicate predicateWithFormat:@"count >= 2"];
    NSSortDescriptor *sortCategory = [NSSortDescriptor sortDescriptorWithKey:@"category" ascending:YES];
    NSSortDescriptor *sortName = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObjects:sortCategory,sortName, nil];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.danciDatabase.managedObjectContext
                                                                          sectionNameKeyPath:@"category"
                                                                                   cacheName:nil];
}

//coredate初始化
-(void) useDocument
{
    if(![[NSFileManager defaultManager] fileExistsAtPath:self.danciDatabase.fileURL.path]){
        //db文件还不存在 创建
        NSLog(@"document file is not exist. create db at[%@]",self.danciDatabase.fileURL.path);
        [self.danciDatabase saveToURL:self.danciDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            //配置查询器
            [self setupFetchedResultsController];
            //创建完成后 初始化album表和word表
            [self dumpDataIntoDocument:self.danciDatabase];
        }];
    }else if(self.danciDatabase.documentState == UIDocumentStateClosed){
        //db存在但未打开 打开
        [self.danciDatabase openWithCompletionHandler:^(BOOL success) {
            [self setupFetchedResultsController];
            //提取待复习的album
            self.albumReview = [Album getReviewAlbum:self.danciDatabase.managedObjectContext];
            NSLog(@"albumReview:%@",self.albumReview);
            //同步user信息
            dispatch_queue_t queue = dispatch_queue_create("merge user", NULL);
            dispatch_async(queue, ^{
                [UserInfo mergerUserWithServer:self.danciDatabase.managedObjectContext];
            });
        }];
    }else if(self.danciDatabase.documentState == UIDocumentStateNormal){
        [self setupFetchedResultsController];
    }else{
        NSLog(@"document状态异常！documentState[%d]",self.danciDatabase.documentState);
    }
}

//加载coredate
-(void) setDanciDatabase:(UIManagedDocument *)danciDatabase
{
    if(!_danciDatabase){
        _danciDatabase = danciDatabase;
        [self useDocument];
    }
}

//初始加载coredate
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 根据首次启动标识，判断是否显示用户引导画面
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
        //        [[[UIAlertView alloc] initWithTitle:@"运行次数检测" message:@"第一次运行" delegate:self cancelButtonTitle:@"请多关照!" otherButtonTitles:nil] show];
        NSLog(@"本程序第一次运行...");
        
        // 更新首次启动的标识
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
        
        [self showUserGuide];
    } else {
        //        [[[UIAlertView alloc] initWithTitle:@"运行次数检测" message:@"运行好多遍啦" delegate:self cancelButtonTitle:@"那又怎样？" otherButtonTitles:nil] show];
        NSLog(@"本程序已运行多次...");
    }
    
    // 加载单词本
    if(!self.danciDatabase) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:DATABASE_VERSION];
        NSLog(@"url of database:[%@]", url);
        self.danciDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 为了使学习主界面的返回按钮没有文字只有图标，在这里去掉title
    self.title = @"";
    UIButton *btnTitle = [[UIButton alloc] init];
    [btnTitle setTitle:@"单词本" forState:UIControlStateNormal];
    [btnTitle setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.navigationItem setTitleView: btnTitle];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(generateReveiwAlbum)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view delegate

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0f;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = ALBUM_CELL_ID;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Album *album = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = album.name;
    int curPoint = [album.point intValue] % [album.count intValue];
    int cycleNum = [album.point intValue] / [album.count intValue] + 1;
    if([album.name isEqualToString:ALBUM_NAME_REVIEW]){
        [cell.textLabel setTextColor:[UIColor blueColor]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"亲 [%d]个单词处于遗忘零界点",[album.count intValue]];
    }else{
        [cell.textLabel setTextColor:[UIColor blackColor]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"总量%d 进度[%d/%d] 第[%d]遍", [album.count intValue], curPoint, [album.count intValue], cycleNum];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *albumName = cell.textLabel.text;
    self.albumSelected = [Album getAlbum:albumName inManagedObjectContext:self.danciDatabase.managedObjectContext];
    self.albumSelected.category = CATEGORY_MY;
    self.albumSelected.opt_time = [NSDate date];
    int curPoint = [self.albumSelected.point intValue] % [self.albumSelected.count intValue];
    int cycleNum = [self.albumSelected.point intValue] / [self.albumSelected.count intValue];
    NSLog(@"now albumSelected. albumName[%@] wordPoint[%d] wordNum[%d]。第[%d]遍", self.albumSelected.name,curPoint,[[self.albumSelected count] intValue], cycleNum);
    
    //执行segua
    [self performSegueWithIdentifier:@"sgGotoStudy" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //要把managedObject、album传递过去
    if([segue.identifier isEqualToString:@"sgGotoStudy"]){
        [segue.destinationViewController setDanciDatabase:self.danciDatabase];
        [segue.destinationViewController setIsNewStudy:TRUE];
        [segue.destinationViewController setAlbum:self.albumSelected];
    }
    else if ([segue.identifier isEqualToString:@"segueConfiguration"]) {
        [segue.destinationViewController setDanciDatabase:self.danciDatabase];
    }
}

#pragma mark - Show user guide view

-(void)showUserGuide{
    // 第一屏
    MYIntroductionPanel *panel1 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:@"选择单词本" description:@"丰富的单词本，创始人的墙裂推荐很有意思哦。点击进入单词学习" image:[UIImage imageNamed:@"panel_1.png"]];
    
    // 第二屏
    MYIntroductionPanel *panel2 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:@"开始学习" description:@"单击单词真人发音，单词例句也有真人朗读哦。图片助记、网友分享的优秀助记神马的，你肯定知道怎么玩的:)" image:[UIImage imageNamed:@"panel_2.png"]];
    
    // 第三屏
    MYIntroductionPanel *panel3 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:@"温故知新" description:@"子曰 温故而知新，可以为师矣。日知其所亡，月无忘其所能，可谓好学也已矣。通过遗忘曲线计算出的处于遗忘零界点的单词，花一小点儿时间就满血满蓝啦!" image:[UIImage imageNamed:@"panel_3.png"]];
    
    // Add panels to an array
    NSArray *panels = @[panel1, panel2, panel3];
    
    //Create the introduction view and set its delegate
//    MYBlurIntroductionView *introductionView = [[MYBlurIntroductionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    MYBlurIntroductionView *introductionView = [[MYBlurIntroductionView alloc] initWithFrame:appRect];
    introductionView.delegate = self;
//    introductionView.BackgroundImageView.image = [UIImage imageNamed:@"Toronto, ON.jpg"];
//    //introductionView.LanguageDirection = MYLanguageDirectionRightToLeft;
    
    //Build the introduction with desired panels
    [introductionView buildIntroductionWithPanels:panels];
    
    //Add the introduction to your view
    [self.parentViewController.view addSubview:introductionView];
}

#pragma mark - MYIntroduction Delegate

-(void)introduction:(MYBlurIntroductionView *)introductionView didChangeToPanel:(MYIntroductionPanel *)panel withIndex:(NSInteger)panelIndex{
    NSLog(@"Introduction did change to panel %d", panelIndex);
    
    //You can edit introduction view properties right from the delegate method!
    //If it is the first panel, change the color to green!
    if (panelIndex == 0) {
        [introductionView setBackgroundColor:[UIColor colorWithRed:155.0f/255.0f green:231.0f/255.0f blue:104.0f/255.0f alpha:1]]; // 绿色
    }
    //If it is the second panel, change the color to blue!
    else if (panelIndex == 1){
        [introductionView setBackgroundColor:[UIColor colorWithRed:77.0f/255.0f green:190.0f/255.0f blue:248.0f/255.0f alpha:1]]; // 蓝色
    }
    //If it is the third panel, change the color to blue!
    else if (panelIndex == 2){
        //        [introductionView setBackgroundColor:[UIColor colorWithRed:247.0f/255.0f green:232.0f/255.0f blue:102.0f/255.0f alpha:1]]; // 黄色
        [introductionView setBackgroundColor:[UIColor colorWithRed:255.0f/255.0f green:108.0f/255.0f blue:108.0f/255.0f alpha:1]]; // 红色
    }
    
    NSString *buttonTitle = (panelIndex == 2 ? @"开始" : @"略过");
    introductionView.RightSkipButton.titleLabel.text = buttonTitle;
}

-(void)introduction:(MYBlurIntroductionView *)introductionView didFinishWithType:(MYFinishType)finishType {
    NSLog(@"Introduction did finish");
    [introductionView removeFromSuperview]; // 从父view中移除
}

-(void) generateReveiwAlbum
{
    NSLog(@"album:%@",self.albumReview);
    if(self.albumReview && [self.albumReview.count intValue] < 2){
        dispatch_queue_t queue = dispatch_queue_create("generate album", NULL);
        dispatch_async(queue, ^{
            self.albumReview = [Album getReviewAlbum: self.danciDatabase.managedObjectContext];
        });
    }
}

@end