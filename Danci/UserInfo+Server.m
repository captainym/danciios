//
//  UserInfo+Server.m
//
//
//  Created by ShiYuming on 13-11-30.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import "UserInfo+Server.h"
#import "DanciServer.h"
#import "StudyOperation+Server.h"

@implementation UserInfo (Server)

//加载user信息。 user只有一个，用户登陆或注册后存在，用户注销则删除掉
+ (UserInfo *) getUser:(NSManagedObjectContext *)context
{
    UserInfo *user = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"UserInfo"];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || [matches count] > 1){
        NSLog(@"warning. user is more than one or NONE!");
        [matches enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSLog(@"dup user:[%@]", obj);
        }];
    }else if([matches count] == 0){
        //新建一个
        user = [NSEntityDescription insertNewObjectForEntityForName:@"UserInfo" inManagedObjectContext:context];
        user.words = @"";
        NSLog(@"create a user of empty");
    }else{
        user = [matches lastObject];
        if(user.words == nil){
            user.words = @"";
        }
        NSLog(@"load a user from coredata. the user is[%@]  mid[%@]",user,user.mid);
    }
    
    return user;
}

+ (UserInfo *) mergerUserWithServer:(NSManagedObjectContext *) context
{
    UserInfo *user = [self getUser:context];
    return [UserInfo mergerUserToServer:user];
}

+ (UserInfo *) mergerUserToServer:(UserInfo *) user
{
    if(user != nil && [user.maxWordNum intValue] > 1 && [user.studyNo intValue] > 1){
        NSLog(@"user:%@",user);
        NSDictionary *userinfo = @{@"studyNo":user.studyNo,
                                   @"word_used":user.comsumeWordNum,
                                   @"word_list":user.words ? user.words:@""};
        NSDictionary *mergerData = [DanciServer mergerUserInfo:userinfo];
        if([[mergerData objectForKey:RETURN_CODE] intValue] == ServerFeedbackTypeOk){
            user.maxWordNum = [NSNumber numberWithInt:[[mergerData objectForKey:@"maxWordNum"] intValue]];
            if([user.comsumeWordNum intValue] < [[mergerData objectForKey:@"comsumeWordNum"]intValue]){
                user.comsumeWordNum = [NSNumber numberWithInt:[[mergerData objectForKey:@"comsumeWordNum"]intValue]];
            }
            //words也要同步 ： server的words数量比本地的多则同步一下
            NSString *wordsServer = [mergerData objectForKey:@"word_list"];
            if([wordsServer length] > [user.words length] + 5){
                user.words = wordsServer;
            }
        }else{
            NSLog(@"merger user info faild. msg[%@]",[mergerData objectForKey:RETURN_VALUE]);
        }
    } else{
        NSLog(@"user not exist. no need to merge user");
    }
    
    return user;
}

//用户登出则删除其帐户信息
+ (void) dropUser:(UserInfo *) user inUIManagedDocument:(UIManagedDocument *) danciDatabase
{
    //清空user全部信息
    user.comsumeWordNum = [NSNumber numberWithInt:0];
    user.maxWordNum = [NSNumber numberWithInt:0];
    user.mid = @"";
    user.recommendStudyNo = [NSNumber numberWithInt:0];
    user.regTime = [[NSDate alloc] initWithTimeIntervalSince1970:0.0];
    user.studyNo = [NSNumber numberWithInt:0];
    user.words = @"";
    
    //删除StudyOperation所有记录
    [StudyOperation deleteAllStudyOperations:danciDatabase.managedObjectContext];
    
    //触发数据库save
    [danciDatabase saveToURL:danciDatabase.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
        NSLog(@"drop user OK. and save changes to DB complete.");
    }];
}

@end
