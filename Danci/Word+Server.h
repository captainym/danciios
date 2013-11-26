//
//  Word+Server.h
//  Danci
//
//  Created by ShiYuming on 13-11-24.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import "Word.h"

@interface Word (Server)

+ (void) initStore:(NSString *)jsonFilePath inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Word *) getWord:(NSString *) paraWord inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Word *) getWordWithInfo:(NSDictionary *) wordinfo inManagedObjectContext:(NSManagedObjectContext *)context;

@end
