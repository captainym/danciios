//
//  CalculatorAppDelegate.h
//  CoreDataPersist
//
//  Created by yuanxj on 13-11-11.
//  Copyright (c) 2013年 yuanxj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DanciAlbumTableViewController.h"

@class DanciAlbumTableViewController;

@interface BIDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) DanciAlbumTableViewController *rootViewController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
