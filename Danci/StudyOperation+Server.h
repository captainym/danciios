//
//  StudyOperation+Server.h
//  Danci
//
//  Created by ShiYuming on 13-11-24.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import "StudyOperation.h"

@interface StudyOperation (Server)

//上传opeation失败后，新建并保存用户的学习操作
+(StudyOperation *) saveStudyOperationWithInfoAfterUploadFailed:(NSDictionary *) info
                    inManagedObjectContext:(NSManagedObjectContext *)context;

//取出之前上传失败的数据 继续上传。上传成功就删掉(调用者会搞) 
+(NSArray *) getStudyOperations:(NSManagedObjectContext *)context;

@end
