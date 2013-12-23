//
//  StudyOperation+Server.h
//  Danci
//
//  Created by ShiYuming on 13-11-24.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import "StudyOperation.h"
#import "DanciServer.h"

typedef enum
{
    studyOperationFlagNone = 0,
    
    studyOperationFlagWordNewStudy = 1,
    studyOperationFlagWordReview = 2,
} studyOperationFlag;

@interface StudyOperation (Server)

//上传opeation失败后，新建并保存用户的学习操作
+(StudyOperation *) saveStudyOperationWithInfoAfterUploadFailed:(NSDictionary *) info
                    inManagedObjectContext:(NSManagedObjectContext *)context;

//取出之前上传失败的数据 继续上传。上传成功就删掉(调用者会搞) 
+(NSArray *) getStudyOperations:(NSManagedObjectContext *)context;

//删除StudyOperation所有记录
+(void) deleteAllStudyOperations:(NSManagedObjectContext *)context;

//查找studyOperation。目前支持的业务是抗遗忘策略：查找到需要复习的单词
+(NSArray *) getStudyOperations:(NSManagedObjectContext *)context
                        OpratetionBeginTime:(NSDate *) optBegin
               OperationEndTime:(NSDate *)optEnd
             studyOperationType:(StudyOperationType) otype
             studyOperationFlag:(studyOperationFlag) flag;

@end
