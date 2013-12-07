//
//  UserInfo+Server.m
//
//
//  Created by ShiYuming on 13-11-30.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import "UserInfo+Server.h"

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
        NSLog(@"create a user of empty");
    }else{
        user = [matches lastObject];
        NSLog(@"load a user from coredata. the user is[%@]  mid[%@]",user,user.mid);
    }
    
    return user;
}

//用户登出则删除其帐户信息
+ (void) dropUser:(NSManagedObjectContext *)context
{
    
}

@end
