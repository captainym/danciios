//
//  Word.h
//  Danci
//
//  Created by HuHao on 13-12-2.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Word : NSManagedObject

@property (nonatomic, retain) NSString * meaning;
@property (nonatomic, retain) NSString * stem;
@property (nonatomic, retain) NSString * txt_tip;
@property (nonatomic, retain) NSString * word;
@property (nonatomic, retain) NSString * yin_biao;

@end
