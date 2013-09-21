//
//  DanciAlbumTableViewController.m
//  Danci
//
//  Created by HuHao on 13-9-20.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import "DanciAlbumTableViewController.h"
#import "DanciWordViewController.h"

#define ALBUM_NAME @"albumName"
#define ALBUM_WORD_POINT @"wordPoint"
#define ALBUM_WORDS @"words"

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
                          @"wordPoint": @"3",
                          @"words":@[@"accident",@"sex",@"friend"],
                         },
                        ]
                      },
                    @{@"category": @"国内考试",
                      @"albums":
                          @[
                              @{
                                  @"albumName": @"四级高频词汇",
                                  @"wordPoint": @"2",
                                  @"words":@[@"hello",@"girl",@"friend"],
                                  },
                              @{
                                  @"albumName": @"六级高频词汇",
                                  @"wordPoint": @"3",
                                  @"words":@[@"accident",@"sex",@"friend"],
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
    return [[self.albums objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"theAlbum";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if(cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    NSDictionary *tmpAlbum = [[self.albums objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSLog(@"the name of the album:%@", [tmpAlbum objectForKey:ALBUM_NAME]);
    cell.textLabel.text = [tmpAlbum objectForKey:ALBUM_NAME];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.albumSelected = [[self.albums objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"gotoStudy"]){
        [segue.destinationViewController setAlbumName: [self.albumSelected objectForKey:ALBUM_NAME]];
        [segue.destinationViewController setWordPoint: [[self.albumSelected objectForKey:ALBUM_WORD_POINT] intValue] ];
         [segue.destinationViewController setWords:[self.albumSelected objectForKey:ALBUM_WORDS]];
        //set delegate. 更新album的断点 
        //[segue.destinationViewController setDelegate:self];
    }
}


@end
