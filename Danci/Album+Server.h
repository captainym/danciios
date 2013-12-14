
//
//  Album+Server.h
//  Danci
//
//  Created by ShiYuming on 13-11-24.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import "Album.h"

#define FILE_INIT_ALBUM @"initfile_album"
#define ALBUM_NAME_REVIEW @"温故而知新"
#define ALBUM_NAME_MY @" 我查过的单词"
#define CATEGORY_MY @"    我选择的单词本"
#define NUM_MAX_REVIEW_ALBUM_LEN 100

@interface Album (Server)

//初始化单词本的存储
+ (void) initStore:(NSString *)jsonFilePath inManagedObjectContext:(NSManagedObjectContext *)context;

//通过album获得所有album全的信息
+ (Album *) getAlbum:(NSString *)albumName inManagedObjectContext:(NSManagedObjectContext *)context;

//获得需要复习的单词，组成抗遗忘策略单词本。这个单词本是不可见的
+ (Album *) getReviewAlbum:(NSManagedObjectContext *)context;


@end
