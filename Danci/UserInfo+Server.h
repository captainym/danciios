//
//  UserInfo+Server.h
//  Danci
//
//  Created by ShiYuming on 13-11-30.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import "UserInfo.h"

@interface UserInfo (Server)

//加载user信息。 user只有一个，用户登陆或注册后存在，用户注销则删除掉
+ (UserInfo *) getUser:(NSManagedObjectContext *) context;

//用户登出则删除其帐户信息及其全部个人记录StudyOperation
+ (void) dropUser:(UserInfo *) user inUIManagedDocument:(UIManagedDocument *) danciDatabase;

//同步用户信息
+ (UserInfo *) mergerUserWithServer:(NSManagedObjectContext *) context;
+ (UserInfo *) mergerUserToServer:(UserInfo *) user;

@end
