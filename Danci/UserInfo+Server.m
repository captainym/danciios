//
//  UserInfo+Server.m
//
//
//  Created by ShiYuming on 13-11-30.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import "UserInfo+Server.h"
#import "DanciServer.h"

@implementation UserInfo (Server)

//加载user信息。 user只有一个，用户登陆或注册后存在，用户注销则删除掉
+ (UserInfo *) getUser:(NSManagedObjectContext *)context
{
    UserInfo *user = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"UserInfo"];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || [matches count] > 1){
        NSLog(@"warning. user is more than one!");
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
    if([user.maxWordNum intValue] > 1 && [user.studyNo intValue] > 1){
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
        }else{
            NSLog(@"merger user info faild. msg[%@]",[mergerData objectForKey:RETURN_VALUE]);
        }
    }else{
        NSLog(@"user not exist. no need to merge user");
    }
    
    return user;
}

//用户登出则删除其帐户信息
+ (void) dropUser:(NSManagedObjectContext *)context
{
    
}

@end
