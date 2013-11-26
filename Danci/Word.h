//
//  Word.h
//  Danci
//
//  Created by ShiYuming on 13-11-24.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Word : NSManagedObject

@property (nonatomic, retain) NSString * word;
@property (nonatomic, retain) NSString * yin_biao;
@property (nonatomic, retain) NSString * meaning;
@property (nonatomic, retain) NSString * stem;
@property (nonatomic, retain) NSString * txt_tip;

@end
