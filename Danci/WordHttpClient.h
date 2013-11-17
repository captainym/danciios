//
//  WordHttpClient.h
//  car_parts
//
//  Created by yuanxj on 13-11-2.
//  Copyright (c) 2013年 yuanxj. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SERVER_URL @"http://dbl-rdtest-3-04.vm.baidu.com:8060/bdc"

@interface WordHttpClient : NSObject

- (NSDictionary*) getWordInfo:(NSString*) word;

- (NSData*) makeHttpRequest:(NSString*)requestUrl
              requestMethod:(NSString*)method
               requestData:(NSDictionary*)data;

- (NSDictionary*) getDictDataByHttp:(NSString*) requestUrl
                      requestMethod:(NSString*) method
                        requestData:(NSDictionary*)data;

@end
