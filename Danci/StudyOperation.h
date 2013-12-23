//
//  StudyOperation.h
//  Danci
//
//  Created by shiyuming on 13-12-23.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface StudyOperation : NSManagedObject

@property (nonatomic, retain) NSNumber * is_upload;
@property (nonatomic, retain) NSDate * opt_time;
@property (nonatomic, retain) NSNumber * otype;
@property (nonatomic, retain) NSString * ovalue;
@property (nonatomic, retain) NSString * word;
@property (nonatomic, retain) NSNumber * flag;

@end
