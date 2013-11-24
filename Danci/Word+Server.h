//
//  Word+Server.h
//  Danci
//
//  Created by HuHao on 13-11-24.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import "Word.h"

@interface Word (Server)

+ (Word *) getWord:(NSString *) paraWord inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Word *) getWordWithInfo:(NSDictionary *) wordinfo inManagedObjectContext:(NSManagedObjectContext *)context;

@end
