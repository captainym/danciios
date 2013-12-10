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

#define ALBUM_CATEGORY @"category"
#define ALBUM_LIST @"albums"
#define ALBUM_NAME @"albumName"
#define ALBUM_WORD_POINT @"wordPoint"
#define ALBUM_WORDS @"words"
#define ALBUM_CELL_ID @"theAlbum"
#define DATABASE_VERSION @"Danci1.0"
#define DATABASE_ALBUM_INIT_FILE @"album"
#define DATABASE_WORD_INIT_FILE @"words"
#define CATEGORY_MY @"    我选择的单词本";

@interface DanciAlbumTableViewController ()

//用户选中的album
@property (nonatomic, strong) Album *albumSelected;

@end

@implementation DanciAlbumTableViewController

@synthesize danciDatabase = _danciDatabase;
@synthesize albumSelected = _albumSelected;

//初始化coredata的内容 第一次
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
        }];
    });
}

//设置查询album
-(void) setupFetchedResultsController
{
    //配置section、查询内容（不要把words列表搞出来了）
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Album"];
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
    
    if(!self.danciDatabase){
        
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:DATABASE_VERSION];
        NSLog(@"url of database:[%@]", url);
        self.danciDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    cell.detailTextLabel.text = [NSString stringWithFormat:@"总量%d 进度[%d/%d] 第[%d]遍", [album.count intValue], curPoint, [album.count intValue], cycleNum];
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

- (IBAction)gotoConfiguration:(id)sender {
    [self performSegueWithIdentifier:@"segueConfiguration" sender:self];
}


#pragma mark - Table view delegate

@end
