//
//  UserInfo.h
//  Danci
//
//  Created by ShiYuming on 13-11-30.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserInfo : NSManagedObject

@property (nonatomic, retain) NSString * mid;
@property (nonatomic, retain) NSNumber * studyNo;
@property (nonatomic, retain) NSNumber * maxWordNum;
@property (nonatomic, retain) NSNumber * comsumeWordNum;
@property (nonatomic, retain) NSDate * regTime;
@property (nonatomic, retain) NSNumber * recommendStudyNo;

@end
