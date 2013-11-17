//
//  WordInterface.m
//  car_parts
//
//  Created by yuanxj on 13-11-2.
//  Copyright (c) 2013年 yuanxj. All rights reserved.
//

#import "WordHttpClient.h"

@implementation WordHttpClient

//暂时只实现get方法，没实现post方法

- (NSData *)makeHttpRequest:(NSString *)requestUrl requestMethod:(NSString *)method requestData:(NSDictionary *)data {
    NSRange has_param = [requestUrl rangeOfString:@"?"];
    
    if (has_param.location == NSNotFound) {
        requestUrl = [NSString stringWithFormat:@"%@?", requestUrl];
    } else {
        requestUrl = [NSString stringWithFormat:@"%@&", requestUrl];
    }
    
    if (data != nil) {
        for(NSString* key in data) {
            NSLog(@"start to get key %@", key);
            NSString* value = (NSString*)[data objectForKey:key];
            NSLog(@"start to transfrom value %@", value);
            //需要对value做一些url编码
            NSString * escapedUrlString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                                NULL,
                                                                                                                (CFStringRef)value,
                                                                                                                NULL,
                                                                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                                kCFStringEncodingUTF8 ));
            NSLog(@"end to transfrom value %@", escapedUrlString);
            requestUrl = [NSString stringWithFormat:@"%@%@=%@&", requestUrl, key, escapedUrlString];
        }
    }
    
    NSLog(@"start to do %@ to %@", method, requestUrl);
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    return response;
}

- (NSDictionary*) getWordInfo:(NSString *)word {
    NSString* wordQueryUrl = [NSString stringWithFormat:@"%@/query/wrap/word/%@", SERVER_URL, word];
    
    NSDictionary* res = [self getDictDataByHttp:wordQueryUrl requestMethod:@"get" requestData:nil];

    return res;
}

-(NSDictionary *)getDictDataByHttp:(NSString *)requestUrl requestMethod:(NSString *)method requestData:(NSDictionary *)data {
    NSData* res = [self makeHttpRequest:requestUrl requestMethod:method requestData:data];
    NSString* aStr = [[NSString alloc] initWithData:res encoding:kCFStringEncodingUTF8];
    NSLog(@"info log%@,", aStr);
    NSError* error = [[NSError alloc] init];
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:res options:NSJSONReadingMutableLeaves error:&error];
    
    return result;
}


@end
