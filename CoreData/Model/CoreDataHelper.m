//
//  CoreDataHelper.m
//  CoreData
//
//  Created by Danyow.Ed on 2017/1/27.
//  Copyright © 2017年 Danyow.Ed. All rights reserved.
//

#import "CoreDataHelper.h"

NSString * storeFilename = @"CoreData.sqlite";

@interface CoreDataHelper ()

@property (nonatomic, strong) NSManagedObjectContext       *context;
@property (nonatomic, strong) NSManagedObjectModel         *model;
@property (nonatomic, strong) NSPersistentStoreCoordinator *coordinator;
@property (nonatomic, strong) NSPersistentStore            *store;

@end

@implementation CoreDataHelper

#pragma mark -  Public method

+ (instancetype)shareHelper
{
    static CoreDataHelper *instance_ = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance_ = [self new];
    });
    return instance_;
}

- (void)setupCoreData
{
    CoreDataLog;
    [self loadStore];
}

- (void)saveContext
{
    CoreDataLog;
    if ([self.context hasChanges]) {
        NSError *error = nil;
        if ([self.context save:&error]) {
            NSLog(@"上下文成功保存改动内容到持续存储区");
        } else {
            NSMustLog(@"上下文保存改动内容失败%@", error);
        }
    } else {
        NSMustLog(@"没有改动内容, 跳过保存");
    }
}

#pragma mark -  Init

- (instancetype)init
{
    if ([super init]) {
        /**
         # model的创建方法有两种
         1. 模糊创建 适用于CoreDataModel文件只有一个的时候。
         ```objc
         [NSManagedObjectModel mergedModelFromBundles:nil]
         ```
         2. 精准创建 适用于CoreDataModel文件有多个的时候。这个如果没有找到对应的文件的话是会报错的
         ```objc
         [[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"CoreData" withExtension:@"momd"]]
         ```
         */
        self.model = [NSManagedObjectModel mergedModelFromBundles:nil];
        self.coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
        self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [self.context setPersistentStoreCoordinator:self.coordinator];
    }
    return self;
}

- (void)loadStore
{
    CoreDataLog;
    if (self.store) {
        return;
    }
    NSError *error = nil;
    
    /** 这个Option的用处就是删除掉-wal文件 */
    NSDictionary *option = @{NSSQLitePragmasOption : @{@"journal_mode" : @"DELETE"}};
    self.store = [self.coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:option error:&error];
    if (!error) {
        NSLog(@"添加存储区成功");
    } else {
        NSMustLog(@"添加存储区失败 %@", error);
    }
}

#pragma mark -  PATHS

- (NSString *)applicationDocumentDirectory
{
    CoreDataLog;
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
}

- (NSURL *)applicationStoreDicretory
{
    CoreDataLog;
    NSURL *storesDirectory = [[NSURL fileURLWithPath:[self applicationDocumentDirectory]] URLByAppendingPathComponent:@"Stores"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if ([fileManager createDirectoryAtURL:storesDirectory
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:&error]) {
        NSLog(@"创建存储区目录成功");
    } else {
        NSMustLog(@"创建存储区目录失败:%@", error);
    }
    return storesDirectory;
}

- (NSURL *)storeURL
{
    CoreDataLog;
    return [[self applicationStoreDicretory] URLByAppendingPathComponent:storeFilename];
}

@end
