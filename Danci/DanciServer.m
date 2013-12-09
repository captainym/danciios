//
//  DanciServer.m
//  Danci
//
//  Created by ShiYuming on 13-11-24.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import "DanciServer.h"
//#import "JSONKit.h"

#define API_KEY @"testapikey"
#define FORMAT_QUERY_TIPS_IMG @"http://acodingfarmer.com/bdc/query/tips/type/img/word/%@/start/%d/count/%d"
#define FORMAT_QUERY_TIPS_TXT @"http://acodingfarmer.com/bdc/query/tips/type/txt/word/%@/start/%d/count/%d"
#define FORMAT_QUERY_TIPS_SENTENCE @"http://acodingfarmer.com/bdc/query/Sentence/word/%@/start/%d/count/%d"
#define FORMAT_QUERY_WORD_INFO @""
#define FORMAT_POST_STUDY_OPERATION @"http://acodingfarmer.com/bdc/action/op"
#define FORMAT_POST_LOGIN @"http://acodingfarmer.com/bdc/action/auth"
#define FORMAT_POST_REGIST @"http://acodingfarmer.com/bdc/action/register"
#define FORMAT_MERGER_USER @"http://acodingfarmer.com/bdc/action/syncUser"

@implementation DanciServer

+ (NSString *)generateDynamicCode
{
    return @"testDynamicCode";
}

//通用的query
+ (NSDictionary *)executeServerFetch:(NSString *) query
{
//    NSString *code = [self generateDynamicCode];
//    query = [NSString stringWithFormat:@"%@&api_key=%@&code=%@", query, API_KEY, code];
    NSLog(@"query is[%@]",query);
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"query added percentEscapeUsingEncoding[%@]",query);
    NSData *jsondata = [[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *results = jsondata ? [NSJSONSerialization JSONObjectWithData:jsondata options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:&error] : nil;
    if(error){
        NSLog(@"[%@ %@] JSON error:%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd),error.localizedDescription);
    }
    NSLog(@"query result is: retcode[%d] retValue[%@]",[[results objectForKey:RETURN_CODE] intValue], [results objectForKey:RETURN_VALUE]);
    if(results && [[results objectForKey:RETURN_CODE] intValue] != ServerFeedbackTypeOk){
        NSLog(@"query failed!");
    }else if(!results){
        NSLog(@"query failed! result is nil. net failed");
        results = @{RETURN_CODE:[NSNumber numberWithInt:ServerFeedbackTypeQueryFailForNetError],
                    RETURN_VALUE:@{}};
    }
    
    return results;
}

+ (void) test
{
//    NSArray *objects = [NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:@"StoreNickName"],
//                        [[UIDevice currentDevice] uniqueIdentifier], [dict objectForKey:@"user_question"],     nil];
//    NSArray *keys = [NSArray arrayWithObjects:@"nick_name", @"UDID", @"user_question", nil];
//    NSDictionary *questionDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
//    
//    NSDictionary *jsonDict = [NSDictionary dictionaryWithObject:questionDict forKey:@"question"];
//    
//    NSString *jsonRequest = [jsonDict JSONRepresentation];
//    
//    NSLog(@"jsonRequest is %@", jsonRequest);
//    
//    NSURL *url = [NSURL URLWithString:@"https://xxxxxxx.com/questions"];
//    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
//                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
//    
//    
//    NSData *requestData = [NSData dataWithBytes:[jsonRequest UTF8String] length:[jsonRequest length]];
//    
//    [request setHTTPMethod:@"POST"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
//    [request setHTTPBody: requestData];
//    
//    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
//    if (connection) {
//        receivedData = [[NSMutableData data] retain];
//    }
//    
    NSString *jsonRequest = [NSString stringWithFormat:@"{\"mid\":\"1345134\",\"pwd\":\"1345134\"}"];
    NSLog(@"Request: %@", jsonRequest);
    
    NSURL *url = [NSURL URLWithString:FORMAT_POST_LOGIN];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSData *requestData = [NSData dataWithBytes:[jsonRequest UTF8String] length:[jsonRequest length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
}

//通用的response
+ (NSDictionary *)executeServerPost:(NSString *) query
                           postData:(NSDictionary *) data
{
    NSString *queryNew = @"";
    for(NSString* key in data) {
//        NSLog(@"start to get key %@", key);
        NSString* value = @"";
        if([[data objectForKey:key] isKindOfClass:[NSString class]]){
            value = [data objectForKey:key];
        }else if([[data objectForKey:key] isKindOfClass:[NSDate class]]){
            value = [value stringByAppendingFormat:@"%f",[[data objectForKey:key] timeIntervalSince1970]];
        }else{
            value = [[data objectForKey:key] stringValue];
        }
//        NSLog(@"start to transfrom value %@", value);
        //需要对value做一些url编码
        NSString * escapedUrlString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                            NULL,
                                                                                                            (CFStringRef)value,
                                                                                                            NULL,
                                                                                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                            kCFStringEncodingUTF8 ));
//        NSLog(@"end to transfrom value %@", escapedUrlString);
        queryNew = [NSString stringWithFormat:@"%@%@=%@&", queryNew, key, escapedUrlString];
    }
    NSData *pdata = [queryNew dataUsingEncoding:NSUTF8StringEncoding];
    
//    NSString *code = [self generateDynamicCode];
//    query = [NSString stringWithFormat:@"%@&api_key=%@&code=%@", query, API_KEY, code];
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:query]];
    [request setHTTPMethod:@"POST"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
//    [request setValue:[NSString stringWithFormat:@"%d", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
//    NSLog(@"data with json[%@]", [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding]);
//    [request setHTTPBody:bodyData];
    [request setHTTPBody:pdata];
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *jsondata = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(error){
        NSLog(@"[%@ %@] sendSynchronousRequest error:%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd),error.localizedDescription);
    }
    
    NSDictionary *results = jsondata ? [NSJSONSerialization JSONObjectWithData:jsondata options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:&error] : nil;
    if(error){
        NSLog(@"[%@ %@] JSON error:%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd),error.localizedDescription);
    }
    if(results && [[results objectForKey:RETURN_CODE] intValue] != ServerFeedbackTypeOk){
        NSLog(@"query failed! retcode[%d] retValu[%@]",[[results objectForKey:RETURN_CODE] intValue], [results objectForKey:RETURN_VALUE]);
    }else if(!results || ![results objectForKey:RETURN_CODE]){
        NSLog(@"query failed! result is nil or not valid[%@]. net failed", results);
        results = @{RETURN_CODE:[NSNumber numberWithInt:ServerFeedbackTypeQueryFailForNetError],
                    RETURN_VALUE:@"internet is nagative"};
    }
    
    NSLog(@"results:%@",results);
    return results;
}

+ (NSArray *) getWordInfo:(NSString *)word
{
    NSString *format = FORMAT_QUERY_WORD_INFO;
    NSString *query = [NSString stringWithFormat: format,word];
    return [[self executeServerFetch:query] objectForKey:RETURN_DATA];
}

+ (NSArray *) getWordTipsImg:(NSString *)word atBegin:(int)begin requestCount:(int)count
{
    NSString *format = FORMAT_QUERY_TIPS_IMG;
    NSString *query = [NSString stringWithFormat:format, word, begin, count];
    return [[self executeServerFetch:query] objectForKey:RETURN_DATA];
}

+ (NSArray *) getWordTipsSentence:(NSString *)word
{
    NSString *format = FORMAT_QUERY_TIPS_SENTENCE;
    NSString *query = [NSString stringWithFormat:format, word, 0, 5];
    return [[self executeServerFetch:query] objectForKey:RETURN_DATA];
}

+ (NSArray *) getWordTipsTxt:(NSString *)word atBegin:(int)begin requestCount:(int)count
{
    NSString *format = FORMAT_QUERY_TIPS_TXT;
    NSString *query = [NSString stringWithFormat:format,word,begin,count];
    return [[self executeServerFetch:query] objectForKey:RETURN_DATA];
}

+ (NSDictionary *) postLogin:(NSDictionary *)loginData
{
    NSString *query = FORMAT_POST_LOGIN;
    return [[self executeServerPost:query postData:loginData] objectForKey:RETURN_DATA];
}

+ (NSDictionary *) postRegist:(NSDictionary *)regData
{
    NSString *query = FORMAT_POST_REGIST;
    return [[self executeServerPost:query postData:regData] objectForKey:RETURN_DATA];
}

+ (int) postStudyOperation:(NSDictionary *)studyData
{
    NSString *query = FORMAT_POST_STUDY_OPERATION;
    return [[[self executeServerPost:query postData:studyData] objectForKey:RETURN_CODE] intValue];
}

+ (NSDictionary *) mergerUserInfo:(NSDictionary *)userInfo
{
    NSString *query = FORMAT_MERGER_USER;
    return [[self executeServerPost:query postData:userInfo] objectForKey:RETURN_DATA];
}

@end
