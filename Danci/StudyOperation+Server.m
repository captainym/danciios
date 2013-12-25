//
//  StudyOperation+Server.m
//  Danci
//
//  Created by ShiYuming on 13-11-24.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import "StudyOperation+Server.h"

@implementation StudyOperation (Server)

+ (StudyOperation *) saveStudyOperationWithInfoAfterUploadFailed:(NSDictionary *)info inManagedObjectContext:(NSManagedObjectContext *)context
{
    StudyOperation *operation = [NSEntityDescription insertNewObjectForEntityForName:@"StudyOperation" inManagedObjectContext:context];
    operation.word = [info objectForKey:@"word"];
    operation.otype = [info objectForKey:@"otype"];
    operation.ovalue = [info objectForKey:@"ovalue"];
    operation.opt_time = [info objectForKey:@"opt_time"];
    operation.flag = [info objectForKey:@"flag"];
    NSError *error = nil;
    if(![context save: &error]){
        NSLog(@"save studyOperation failed! msg:%@", [error localizedDescription]);
    }
    return operation;
}

+ (NSArray *) getStudyOperations:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"StudyOpetation"];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    NSLog(@"load出operation的总数是[%d]",[matches count]);
    
    return matches;
}

+(void) deleteAllStudyOperations:(NSManagedObjectContext *)context
{
    NSFetchRequest *requestOpt = [[NSFetchRequest alloc] initWithEntityName:@"StudyOperation"];
    NSError *error = nil;
    NSArray *allStudyOperations = [context executeFetchRequest:requestOpt error:&error];
    [allStudyOperations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"debug: now delete [%d] studyOperate:%@", idx, obj);
        [context deleteObject:obj];
    }];
}

+(NSArray *) getStudyOperations:(NSManagedObjectContext *)context
            OpratetionBeginTime:(NSDate *) optBegin
               OperationEndTime:(NSDate *)optEnd
             studyOperationType:(StudyOperationType) otype
             studyOperationFlag:(studyOperationFlag)flag
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"StudyOperation"];
    request.predicate = [NSPredicate predicateWithFormat:@"(opt_time >= %@) AND (opt_time <= %@) AND (otype == %d OR %d == %d) AND (flag == %d OR %d == %d)", optBegin, optEnd, otype, otype, StudyOperationTypeNone,flag,flag,studyOperationFlagNone];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    return matches;
}

@end
