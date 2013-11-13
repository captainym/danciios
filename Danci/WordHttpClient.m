//
//  WordInterface.m
//  car_parts
//
//  Created by yuanxj on 13-11-2.
//  Copyright (c) 2013年 yuanxj. All rights reserved.
//

#import "WordHttpClient.h"

@implementation WordHttpClient

- (NSDictionary*) getWordInfo:(NSString *)word {
    
}

//暂时只实现get方法，没实现post方法
- (NSData *)makeHttpRequest:(NSString*) url:(NSString *)method :(NSDictionary *)data {
    NSRange has_param = [url rangeOfString:@"?"];
    
    if (has_param.location == NSNotFound) {
        url = [NSString stringWithFormat:@"%@?", url];
    } else {
        url = [NSString stringWithFormat:@"%@&", url];
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
            url = [NSString stringWithFormat:@"%@%@=%@&", url, key, escapedUrlString];
        }
    }

    NSLog(@"start to do %@ to %@", method, url);    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    return response;
}

- (NSDictionary*) getDictDataByHttp:(NSString *)url :(NSString *)method :(NSDictionary *)data {
    NSData* res = [self makeHttpRequest:url :method :data];
    NSError* error = [[NSError alloc] init];
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:res options:NSJSONReadingMutableLeaves error:&error];

    return result;
}

@end
