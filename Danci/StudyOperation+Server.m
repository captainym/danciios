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

@end
