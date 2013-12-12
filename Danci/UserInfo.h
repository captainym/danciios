//
//  UserInfo.h
//  Danci
//
//  Created by zhenghao on 12/12/13.
//  Copyright (c) 2013 mx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * comsumeWordNum;
@property (nonatomic, retain) NSNumber * maxWordNum;
@property (nonatomic, retain) NSString * mid;
@property (nonatomic, retain) NSNumber * recommendStudyNo;
@property (nonatomic, retain) NSDate * regTime;
@property (nonatomic, retain) NSNumber * studyNo;
@property (nonatomic, retain) NSString * words;

@end
