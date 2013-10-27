//
//  DanciAlbumTableViewController.m
//  Danci
//
//  Created by HuHao on 13-9-20.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import "DanciAlbumTableViewController.h"
#import "DanciWordViewController.h"

#define ALBUM_CATEGORY @"category"
#define ALBUM_LIST @"albums"
#define ALBUM_NAME @"albumName"
#define ALBUM_WORD_POINT @"wordPoint"
#define ALBUM_WORDS @"words"
#define ALBUM_CELL_ID @"theAlbum"

@interface DanciAlbumTableViewController ()
//用户选中的album
@property (nonatomic, strong) NSDictionary *albumSelected;

@end

@implementation DanciAlbumTableViewController

@synthesize albums = _albums;
@synthesize albumSelected = _albumSelected;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //造一些假数据 album
    self.albums = @[
                    @{@"category": @"最近学习的单词本",
                      @"albums":
                      @[
                        @{
                          @"albumName": @"六级高频词汇",
                          @"wordPoint": @"1",
                          @"words":@[@"accident",@"sex",@"psychology"],
                         },
                        ]
                      },
                    @{@"category": @"国内考试",
                      @"albums":
                          @[
                              @{
                                  @"albumName": @"四级高频词汇",
                                  @"wordPoint": @"2",
                                  @"words":@[@"hello",@"psychology",@"psychology"],
                                  },
                              @{
                                  @"albumName": @"六级高频词汇",
                                  @"wordPoint": @"3",
                                  @"words":@[@"accident",@"sex",@"psychology"],
                                  },
                            ]
                      },
                    ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.albums count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.albums objectAtIndex:section] objectForKey:ALBUM_LIST] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = ALBUM_CELL_ID;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary *tmpAlbum = [[[self.albums objectAtIndex:indexPath.section] objectForKey:ALBUM_LIST] objectAtIndex:indexPath.row];
    NSLog(@"the name of the album:%@", [tmpAlbum objectForKey:ALBUM_NAME]);
    cell.textLabel.text = [tmpAlbum objectForKey:ALBUM_NAME];
    int wordsNum = [[tmpAlbum objectForKey:ALBUM_WORDS] count];
    int wordPoint = [[tmpAlbum objectForKey:ALBUM_WORD_POINT] intValue];
    cell.detailTextLabel.text = [[NSString class] stringWithFormat:@"总量%d。 学习到第%d个单词", wordsNum, wordPoint];
    NSLog(@"总量%d。 学习到第%d个单词. label[%@]", wordsNum, wordPoint, cell.detailTextLabel.text);
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *tmpAlbums = [self.albums objectAtIndex:section];
    NSString *sectionTitle = [tmpAlbums objectForKey:ALBUM_CATEGORY];
    return sectionTitle;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.albumSelected = [[[self.albums objectAtIndex:indexPath.section] objectForKey:ALBUM_LIST] objectAtIndex:indexPath.row];
    NSLog(@"now albumSelected. albumName[%@] wordPoint[%@] wordNum[%d]",
          [self.albumSelected objectForKey: ALBUM_NAME],
          [self.albumSelected objectForKey: ALBUM_WORD_POINT],
          [[self.albumSelected objectForKey: ALBUM_WORDS] count]);
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    self.albumSelected = [[[self.albums objectAtIndex:1] objectForKey:ALBUM_LIST] objectAtIndex:0];
//    NSLog(@"now albumSelected. albumName[%@] wordPoint[%@] wordNum[%d]",
//          [self.albumSelected objectForKey: ALBUM_NAME],
//          [self.albumSelected objectForKey: ALBUM_WORD_POINT],
//          [[self.albumSelected objectForKey: ALBUM_WORDS] count]);
    
    if([segue.identifier isEqualToString:@"gotoStudy"]){
        [segue.destinationViewController setAlbumName: [self.albumSelected objectForKey:ALBUM_NAME]];
        [segue.destinationViewController setWordPoint: [[self.albumSelected objectForKey:ALBUM_WORD_POINT] intValue] ];
        [segue.destinationViewController setWords:[self.albumSelected objectForKey:ALBUM_WORDS]];
        [segue.destinationViewController setIsNewStudy:TRUE];
        [segue.destinationViewController setIsReview:FALSE];
    }
}

#pragma mark - Table view delegate

@end
