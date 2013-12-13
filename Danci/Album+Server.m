//
//  Album+Server.m
//  Danci
//
//  Created by ShiYuming on 13-11-24.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import "Album+Server.h"

@implementation Album (Server)

+ (void) initStore:(NSString *)jsonFilePath inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSDate *begin = [NSDate date];
    NSError *error = nil;
    NSData *jsondata = [NSData dataWithContentsOfFile:jsonFilePath];
//    NSLog(@"raw:%@",jsondata);
    NSArray *objects = [NSJSONSerialization JSONObjectWithData:jsondata options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:&error];
//    NSLog(@"jsong objects of word: %@ . error[%@]",objects,error.localizedDescription);
    [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Album *album = [NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext:context];
        album.category = [obj objectForKey:@"category"];
        album.name = [obj objectForKey:@"name"];
        album.words = [obj objectForKey:@"words"];
        album.point = [NSNumber numberWithInt:[[obj objectForKey:@"point"] intValue]];
        album.count = [NSNumber numberWithInt:[[obj objectForKey:@"count"] intValue]];
        album.opt_time = [NSDate date];
        NSLog(@"insert a album: name[%@] ",album.name);
        NSError *errorLoc = nil;
        if(![context save:&errorLoc]){
            NSLog(@"save album error:%@",[errorLoc localizedDescription]);
        }
    }];
    NSDate *end = [NSDate date];
    NSLog(@"+++++++++++++init album used[%f]", [end timeIntervalSinceDate:begin]);
    
}

+ (Album *) getAlbum:(NSString *)albumName inManagedObjectContext:(NSManagedObjectContext *)context;
{
    Album *album = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Album"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@",albumName];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if(!matches || [matches count]>1){
        NSLog(@"存在相同名字的album！ album［%@］",albumName);
    }else if (matches == 0){
        NSLog(@"album名字不合法 [%@]",albumName);
    }else{
        album = [matches lastObject];
    }
    
    return album;
}

@end
