//
//  WordInterface.h
//  car_parts
//
//  Created by yuanxj on 13-11-2.
//  Copyright (c) 2013年 yuanxj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WordHttpClient : NSObject

- (NSDictionary*) getWordInfo:(NSString*) word;

- (NSData*) makeHttpRequest:(NSString*) url:(NSString*) method:(NSDictionary*) data;

- (NSDictionary*) getDictDataByHttp:(NSString*) url:(NSString*) method:(NSDictionary*) data;

@end
