//
//  Album.h
//  Danci
//
//  Created by HuHao on 13-11-24.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Album : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * words;
@property (nonatomic, retain) NSNumber * point;

@end
