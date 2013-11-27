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
#define RETURN_CODE @"status"
#define RETURN_VALUE @"msg"
#define RETURN_DATA @"data"
#define FORMAT_QUERY_TIPS_IMG @"http://acodingfarmer.com/bdc/query/tips/type/img/word/%@/start/%d/count/%d"
#define FORMAT_QUERY_TIPS_TXT @"http://acodingfarmer.com/bdc/query/tips/type/txt/word/%@/start/%d/count/%d"
#define FORMAT_QUERY_TIPS_SENTENCE @"http://acodingfarmer.com/bdc/query/Sentence/word/%@/start/%d/count/%d"
#define FORMAT_QUERY_WORD_INFO @""
#define FORMAT_POST_STUDY_OPERATION @"http://acodingfarmer.com/bdc/action/auth"
#define FORMAT_POST_LOGIN @"http://acodingfarmer.com/bdc/action/auth"
#define FORMAT_POST_REGIST @"http://acodingfarmer.com/bdc/action/register"

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
    NSLog(@"query added percentEscapeUsingEncoding[%@]",query);
    NSData *jsondata = [[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *results = jsondata ? [NSJSONSerialization JSONObjectWithData:jsondata options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:&error] : nil;
    if(error){
        NSLog(@"[%@ %@] JSON error:%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd),error.localizedDescription);
    }
    if(results && [[results objectForKey:RETURN_CODE] intValue] != ServerFeedbackTypeOk){
        NSLog(@"query failed! retcode[%d] retValu[%@]",[[results objectForKey:RETURN_CODE] intValue], [results objectForKey:RETURN_VALUE]);
    }else if(!results){
        NSLog(@"query failed! result is nil. net failed");
        results = @{RETURN_CODE:[NSNumber numberWithInt:ServerFeedbackTypeQueryFailForNetError],
                    RETURN_VALUE:@"internet is nagative"};
    }
    
    NSLog(@"results:%@",results);
    return results;
}

//通用的response
+ (NSDictionary *)executeServerPost:(NSString *) query
                           postData:(NSDictionary *) data
{
//    NSString *code = [self generateDynamicCode];
//    query = [NSString stringWithFormat:@"%@&api_key=%@&code=%@", query, API_KEY, code];
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:query]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"text/json" forHTTPHeaderField:@"Content-Type"];
//    NSString *strBody = [data JSONString];
//    [request setHTTPBody:[strBody dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:true]];
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
    NSLog(@"data with json[%@]", [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding]);
    [request setHTTPBody:bodyData];
    
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
    }else if(!results){
        NSLog(@"query failed! result is nil. net failed");
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

+ (NSDictionary *) getWordTipsTxt:(NSString *)word atBegin:(int)begin requestCount:(int)count
{
    NSString *format = FORMAT_QUERY_TIPS_TXT;
    NSString *query = [NSString stringWithFormat:format,word,begin,count];
    return [self executeServerFetch:query];
}

+ (int) postLogin:(NSDictionary *)loginData
{
    NSString *query = FORMAT_POST_LOGIN;
    return [[[self executeServerPost:query postData:loginData] objectForKey:RETURN_CODE] intValue];
}

+ (int) postRegist:(NSDictionary *)regData
{
    NSString *query = FORMAT_POST_REGIST;
    return [[[self executeServerPost:query postData:regData] objectForKey:RETURN_CODE] intValue];
}

+ (int) postStudyOperation:(NSDictionary *)studyData
{
    NSString *query = FORMAT_POST_STUDY_OPERATION;
    return [[[self executeServerPost:query postData:studyData] objectForKey:RETURN_CODE] intValue];
}

@end
