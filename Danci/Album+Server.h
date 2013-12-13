//
//  Album+Server.h
//  Danci
//
//  Created by ShiYuming on 13-11-24.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import "Album.h"

#define FILE_INIT_ALBUM @"initfile_album"

@interface Album (Server)

+ (void) initStore:(NSString *)jsonFilePath inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Album *) getAlbum:(NSString *)albumName inManagedObjectContext:(NSManagedObjectContext *)context;

//+ (Album *) getReviewAlbum:(NSManagedObjectContext *)context;

@end
