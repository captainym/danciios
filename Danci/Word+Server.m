//
//  Word+Server.m
//  Danci
//sunqx1984
//  Created by ShiYuming on 13-11-24.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import "Word+Server.h"
#import "DanciServer.h"

@implementation Word (Server)

+ (void) initStore:(NSString *)jsonFilePath inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSError *error = nil;
    NSArray *objects = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonFilePath] options:kNilOptions error:&error];
    NSLog(@"jsong objects of word: %@",objects);
    [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Word *aWord = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:context];
        aWord.word = [obj objectForKey:@"word"];
        aWord.yin_biao = [obj objectForKey:@"yin_biao"];
        aWord.meaning = [obj objectForKey:@"meaning"];
        aWord.stem = [obj objectForKey:@"stem"];
        NSError *errorLoc = nil;
        if(![context save:&errorLoc]){
            NSLog(@"save word error:%@",[errorLoc localizedDescription]);
        }
    }];
}

+ (Word *) getWord:(NSString *)paraWord inManagedObjectContext:(NSManagedObjectContext *)context
{
    Word *word = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
    request.predicate = [NSPredicate predicateWithFormat:@"%@ = %@", WORD_WORD, paraWord];
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey: WORD_WORD ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDesc];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || [matches count] > 1){
        //出现重复单词！ 这不应该的 删掉一个
        if(matches && [matches count] > 1){
            NSLog(@"warning 还没实现的:出现重复单词！ 这不应该的 删掉一个 word[%@]",paraWord);
        }
    }else if ([matches count] == 0){
        //新的word 数据库里还木有 擅入一个吧
        word = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:context];
    }else{
        word = [matches lastObject];
    }
    
    return word;
}

+ (Word *) getWordWithInfo:(NSDictionary *)wordinfo inManagedObjectContext:(NSManagedObjectContext *)context
{
    Word *word = nil;
    NSString *paraWord = [wordinfo objectForKey:WORD_WORD];
    word = [self getWord:paraWord inManagedObjectContext:context];
    
    //填充word：字段在wordinfo里存在，就用wordinfo里的字段来更新word
    if (word) {
        
    }
    
    return word;
}

@end
