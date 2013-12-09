//
//  Word+Server.m
//  Danci
//sunqx1984
//  Created by ShiYuming on 13-11-24.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import "Word+Server.h"
//#import "DanciServer.h"

@implementation Word (Server)

+ (void) initStore:(NSString *)jsonFilePath inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSError *error = nil;
    NSArray *objects = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonFilePath] options:kNilOptions error:&error];
//    NSLog(@"jsong objects of word: %@",objects);
    [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"idx[%d]",idx);
        Word *aWord = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:context];
        aWord.word = [obj objectForKey:@"word"]==nil ? @"":[obj objectForKey:@"word"];
        aWord.yin_biao = [obj objectForKey:@"yinbiao"]==nil ? @"":[obj objectForKey:@"yinbiao"];;
        aWord.meaning = [obj objectForKey:@"meaning"]==nil ? @"":[obj objectForKey:@"meaning"];;
        aWord.stem = [obj objectForKey:@"stem"]==nil ? @"":[obj objectForKey:@"stem"];;
        NSError *errorLoc = nil;
        if(![context save:&errorLoc]){
            NSLog(@"init save word error:%@",[errorLoc localizedDescription]);
        }else{
//            NSLog(@"init save a word:%@",aWord);
        }
    }];
}

+ (Word *) getWord:(NSString *)paraWord inManagedObjectContext:(NSManagedObjectContext *)context
{
    Word *word = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
    request.predicate = [NSPredicate predicateWithFormat:@"word = %@", paraWord];
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey: @"word" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDesc];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || [matches count] > 1){
        //出现重复单词！ 这不应该的 删掉一个
        if(matches && [matches count] > 1){
            NSLog(@"warning 还没实现的:出现重复单词！ 这不应该的 删掉一个 word[%@]",paraWord);
        }
    }else if ([matches count] == 0){
        //word不不存在
        NSLog(@"word[%@] not exist! predicate[%@]",paraWord, request.predicate);
    }else{
        word = [matches lastObject];
    }
    
    return word;
}

+ (Word *) getWordWithInfo:(NSDictionary *)wordinfo inManagedObjectContext:(NSManagedObjectContext *)context
{
    Word *word = nil;
    NSString *paraWord = [wordinfo objectForKey:@"word"];
    word = [self getWord:paraWord inManagedObjectContext:context];
    
    //填充word：字段在wordinfo里存在，就用wordinfo里的字段来更新word
    if (word) {
        
    }
    
    return word;
}

@end
