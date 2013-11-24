//
//  StudyOperation.h
//  Danci
//
//  Created by HuHao on 13-11-24.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface StudyOperation : NSManagedObject

@property (nonatomic, retain) NSString * word;
@property (nonatomic, retain) NSNumber * otype;
@property (nonatomic, retain) NSString * ovalue;
@property (nonatomic, retain) NSNumber * is_upload;
@property (nonatomic, retain) NSDate * opt_time;

@end
