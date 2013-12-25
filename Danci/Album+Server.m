//
//  Album+Server.m
//  Danci
//
//  Created by ShiYuming on 13-11-24.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import "Album+Server.h"
#import "StudyOperation+Server.h"

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

//merge wordLists
+ (void) mergeArrayList:(NSMutableArray *) wordsList candidateList:(NSArray *) candidates isNeedMergeFuzzeWords:(BOOL) needFuzze subSet:(NSArray *) wordsOk
{
    [candidates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        StudyOperation *curObj = obj;
        switch ([curObj.otype intValue]) {
            case StudyOperationTypeFeedbackNagative:
                if(![wordsList containsObject:curObj.word] && ![wordsOk containsObject:curObj.word]){
                    [wordsList addObject:curObj.word];
                }
                break;
                
            default:
                break;
        }
    }];
    if(needFuzze){
        [candidates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            StudyOperation *curObj = obj;
            switch ([curObj.otype intValue]) {
                case StudyOperationTypeFeedbackFuzzy:
                    if(![wordsList containsObject:curObj.word] && ![wordsOk containsObject:curObj.word]){
                        [wordsList addObject:curObj.word];
                    }
                    break;
                    
                default:
                    break;
            }
        }];
    }
}

+ (Album *) getReviewAlbum:(NSManagedObjectContext *)context
{
    Album *album = nil;
    
    //加载album。第一次木有，要创建一个
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Album"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", ALBUM_NAME_REVIEW];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if(!matches || [matches count] > 1){
        NSLog(@"！！！！！！！！！居然有两个抗遗忘");
        for(Album *dupAlbum in matches){
            [context deleteObject:dupAlbum];
        }
        //create a new one
        album = [NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext:context];
        album.name = ALBUM_NAME_REVIEW;
        album.category = CATEGORY_MY;
    }else if([matches count] == 0){
        //create a new one
        album = [NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext:context];
        album.name = ALBUM_NAME_REVIEW;
        album.category = CATEGORY_MY;
    }else{
        album = [matches lastObject];
    }
    album.words = @"";
    album.count = [NSNumber numberWithInt:0];
    album.point = [NSNumber numberWithInt:1];
    
    //12小时内已经掌握的单词
    NSDate *begin = [NSDate dateWithTimeIntervalSinceNow:(-3600.0 * 12)];
    NSDate *end = [NSDate dateWithTimeIntervalSinceNow:(-3600.0 * 0)];
    NSArray *wordsOkWithdaySO = [StudyOperation getStudyOperations:context OpratetionBeginTime:begin OperationEndTime:end studyOperationType:StudyOperationTypeFeedbackOk studyOperationFlag:studyOperationFlagNone];
    NSMutableArray *wordsOkWithday = [[NSMutableArray alloc] init];
    [wordsOkWithdaySO enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        StudyOperation *curObj = obj;
        if(![wordsOkWithday containsObject:curObj.word]){
            [wordsOkWithday addObject:curObj.word];
        }
    }];
    
    //从studyOperation那里找需要复习的单词
    //1天前
    begin = [NSDate dateWithTimeIntervalSinceNow:(-3600.0 * 24)];
    end = [NSDate dateWithTimeIntervalSinceNow:(-3600.0 * 12)];
    NSArray *review1 = [StudyOperation getStudyOperations:context OpratetionBeginTime:begin OperationEndTime:end studyOperationType:StudyOperationTypeNone studyOperationFlag:studyOperationFlagWordNewStudy];
    NSLog(@"get words within 24 hours. num[%d]: [%@]", [review1 count], review1);
    //2天前
    begin = [NSDate dateWithTimeIntervalSinceNow:(-3600.0 * 24 * 2)];
    end = [NSDate dateWithTimeIntervalSinceNow:(-3600.0 * 24 * 1)];
    NSArray *review2 = [StudyOperation getStudyOperations:context OpratetionBeginTime:begin OperationEndTime:end studyOperationType:StudyOperationTypeNone studyOperationFlag:studyOperationFlagWordNewStudy];
    NSLog(@"get words 2 days ago. num[%d]: [%@]", [review2 count], review2);
    //4天前
    begin = [NSDate dateWithTimeIntervalSinceNow:(-3600.0 * 24 * 4)];
    end = [NSDate dateWithTimeIntervalSinceNow:(-3600.0 * 24 * 3)];
    NSArray *review4 = [StudyOperation getStudyOperations:context OpratetionBeginTime:begin OperationEndTime:end studyOperationType:StudyOperationTypeNone studyOperationFlag:studyOperationFlagWordNewStudy];
    NSLog(@"get words 4 days ago. num[%d]: [%@]", [review4 count], review4);
    //7天前
    begin = [NSDate dateWithTimeIntervalSinceNow:(-3600.0 * 24 * 7)];
    end = [NSDate dateWithTimeIntervalSinceNow:(-3600.0 * 24 * 6)];
    NSArray *review7 = [StudyOperation getStudyOperations:context OpratetionBeginTime:begin OperationEndTime:end studyOperationType:StudyOperationTypeNone studyOperationFlag:studyOperationFlagWordNewStudy];
    NSLog(@"get words 7 days ago. num[%d]: [%@]", [review7 count], review7);
    //15天前
    begin = [NSDate dateWithTimeIntervalSinceNow:(-3600.0 * 24 * 15)];
    end = [NSDate dateWithTimeIntervalSinceNow:(-3600.0 * 24 * 14)];
    NSArray * review15 = [StudyOperation getStudyOperations:context OpratetionBeginTime:begin OperationEndTime:end studyOperationType:StudyOperationTypeNone studyOperationFlag:studyOperationFlagWordNewStudy];
    NSLog(@"get words 15 days ago. num[%d]: [%@]", [review15 count], review15);
    
    //把需要复习的都加入复习album，但要和24小时内已经掌握的单词做差集。这个实现方法太优雅了！我给自己点个赞！近乎完美地处理了和正常album、studyOperation的关系。
    NSMutableArray *words = [[NSMutableArray alloc] init];
    [self mergeArrayList:words candidateList:review1 isNeedMergeFuzzeWords:TRUE subSet:wordsOkWithday];
    [self mergeArrayList:words candidateList:review2 isNeedMergeFuzzeWords:TRUE subSet:wordsOkWithday];
    [self mergeArrayList:words candidateList:review4 isNeedMergeFuzzeWords:FALSE subSet:wordsOkWithday];
    [self mergeArrayList:words candidateList:review7 isNeedMergeFuzzeWords:FALSE subSet:wordsOkWithday];
    [self mergeArrayList:words candidateList:review15 isNeedMergeFuzzeWords:FALSE subSet:wordsOkWithday];
    NSRange range;
    range.location = 1;
    range.length = NUM_MAX_REVIEW_ALBUM_LEN < [words count] ? NUM_MAX_REVIEW_ALBUM_LEN : [words count];
    if(range.location >= range.length){
        return album;
    }
    NSString *albumWords = [words firstObject];
    range.length = range.length - 1;
    for (NSString *word in [words subarrayWithRange:range]) {
        albumWords = [albumWords stringByAppendingFormat:@"|%@", word];
    }
    album.words = albumWords;
    album.count = [NSNumber numberWithInt:range.length + 1];
    
    return album;
}

@end
