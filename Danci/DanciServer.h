//  放置和server交互的东西 调用这里方法必须用多线程！否则会hung住
//  DanciServer.h
//  Danci
//
//  Created by ShiYuming on 13-11-24.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WORD_WORD @"word"
#define WORD_YINGBIAO @"yin_biao"
#define WORD_FAYIN @"fayin"
#define WORD_MEANING @"meaning"
#define WORD_STEM @"stem"
#define WORD_TXT_TIP @"txt_tip"
#define WORD_TIPS_TXT @"tips_txt"
#define WORD_TIPS_IMG @"tips_img"
#define WORD_TIPS_SENTENCE @"tips_sentence"

typedef enum
{
    StudyOperationTypeSeletTipImg = 1,
    StudyOperationTypeSelectTipTxt = 2,
    StudyOperationTypeEditTip = 3,
    
    StudyOperationTypeFeedbackOk = 10,
    StudyOperationTypeFeedbackFuzzy = 11,
    StudyOperationTypeFeedbackNagative = 12,
} StudyOperationType;

typedef enum
{
    ServerFeedbackTypePostStudyOTypeOk = 1,
    ServerFeedbackTypePostStudyOTypeFailForIllegal = 2,
    ServerFeedbackTypePostStudyOTypeFailForServerError = 3,
    ServerFeedbackTypePostStudyOTypeFailForNetError = 4,
    
    ServerFeedbackTypePostLoginOk = 11,
    ServerFeedbackTypePostLoginFailForPwd = 12,
    ServerFeedbackTypePostLoginFailForServerError = 13,
    ServerFeedbackTypePostLoginFailForNetError = 14,
    
    ServerFeedbackTypePostRegistOk = 21,
    ServerFeedbackTypePostRegistFailForUsernameNagative = 22,
    ServerFeedbackTypePostRegistFailForServerError  = 23,
    ServerFeedbackTypePostRegistFailForNetError = 24,
    
    ServerFeedbackTypeQueryOk = 31,
    ServerFeedbackTypeQueryFailed = 32,
    ServerFeedbackTypeQueryFailForNetError = 33,
} ServerFeedbackType;

@interface DanciServer : NSObject

//从server取得word info。适用：word的基本信息如stem、meaing等有更新，则取代coredate中的内容。在第一版用的很少
+ (NSDictionary *) getWordInfo:(NSString *) word;

//从server请求img tips。 指定起止 
+ (NSDictionary *) getWordTipsImg:(NSString *) word atBegin:(int) begin requestCount:(int) count;

//从server请求txt tip。指定起止
+ (NSDictionary *) getWordTipsTxt:(NSString *) word atBegin:(int) begin requestCount:(int) count;

//将学习信息上传到server 反馈状态是枚举 ServeFeedbackType
+ (int) postStudyOperation:(NSDictionary *) studyData;

//登陆校验 反馈状态是枚举 ServeFeedbackType
+ (int) postLogin:(NSDictionary *)loginData;

//注册校验 反馈状态是枚举 ServeFeedbackType
+ (int) postRegist:(NSDictionary *)regData;

@end


