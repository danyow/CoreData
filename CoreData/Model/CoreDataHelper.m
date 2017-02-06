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
    
    BOOL userMigrationManager = NO;
    if (userMigrationManager && [self isMigrationNecessaryForStore:[self storeURL]]) {
        [self performBackgroundManagedMigrationForStore:[self storeURL]];
    } else {
        /** 这个Option的用处就是删除掉-wal文件 */
        NSDictionary *option =
        @{NSSQLitePragmasOption : @{@"journal_mode" : @"DELETE"},
          NSMigratePersistentStoresAutomaticallyOption : @YES,
          NSInferMappingModelAutomaticallyOption : @YES};
        NSError *error = nil;
        self.store = [self.coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:option error:&error];
        if (!error) {
            NSLog(@"添加存储区成功");
        } else {
            NSMustLog(@"添加存储区失败 %@", error);
        }
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

#pragma mark -  Migration manager

- (BOOL)isMigrationNecessaryForStore:(NSURL *)storeURL
{
    CoreDataLog;
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self storeURL].path]) {
        NSLog(@"跳过迁移, 数据文件缺失");
        return NO;
    }
    NSError *error = nil;
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:storeURL options:nil error:&error];
    NSManagedObjectModel *destinationModel = self.coordinator.managedObjectModel;
    if ([destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata]) {
        NSLog(@"跳过迁移, 数据以前迁移完毕");
        return NO;
    }
    return YES;
}

- (BOOL)migrationStore:(NSURL *)sourceStore
{
    CoreDataLog;
    BOOL success = NO;
    NSError *error = nil;
    ///MARK:  第一步：收集数据-> 元数据、源模型、目标模型、映射模型
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:sourceStore options:nil error:&error];
    NSManagedObjectModel *sourceModel = [NSManagedObjectModel mergedModelFromBundles:nil forStoreMetadata:sourceMetadata];
    NSManagedObjectModel *destinModel = self.model;
    NSMappingModel *mappingModel = [NSMappingModel mappingModelFromBundles:nil forSourceModel:sourceModel destinationModel:destinModel];
    ///MARK:  第二步：执行迁移，同时确定在映射模型不为空的前提下
    if (mappingModel) {
        NSError *error = nil;
        NSMigrationManager *migrationManager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel destinationModel:destinModel];
        [migrationManager addObserver:self forKeyPath:@"migrationProgress" options:NSKeyValueObservingOptionNew context:NULL];
        NSURL *destinStore = [[self applicationStoreDicretory] URLByAppendingPathComponent:@"Temp.sqlite"];
        success = [migrationManager migrateStoreFromURL:sourceStore type:NSSQLiteStoreType options:nil withMappingModel:mappingModel toDestinationURL:destinStore destinationType:NSSQLiteStoreType destinationOptions:nil error:&error];
        if (success) {
            ///MARK:  第三步：替换老的存储空间到新的迁移存储空间 自定义方法
            if ([self replaceStore:sourceStore withStore:destinStore]) {
                NSLog(@"成功迁移%@到当前模型", sourceStore.path);
                [migrationManager removeObserver:self forKeyPath:@"migrationProgress"];
            }
        } else {
            NSLog(@"迁移失败%@", error);
        }
    } else {
        NSLog(@"迁移失败，Mapping 模型为空");
    }
    return YES;
}

- (BOOL)replaceStore:(NSURL *)old withStore:(NSURL *)new
{
    BOOL success = NO;
    NSError *error = nil;
    ///MARK:  这里是可以备份老的存储空间的
    if ([[NSFileManager defaultManager] removeItemAtURL:old error:&error]) {
        error = nil;
        if ([[NSFileManager defaultManager] moveItemAtURL:new toURL:old error:&error]) {
            success = YES;
        } else {
            NSLog(@"新的存储空间替换老的存储空间失败%@", error);
        }
    } else {
        NSLog(@"删除老的存储空间失败%@", error);
    }
    return success;
}

#pragma mark -  event handle

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"migrationProgress"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            float progress = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
            self.migrationVC.progressView.progress = progress;
            int percentage = progress * 100;
            NSString *string = [NSString stringWithFormat:@"%i%%", percentage];
            NSLog(@"%@", string);
            self.migrationVC.progressLabel.text = string;
        });
    }
}

- (void)performBackgroundManagedMigrationForStore:(NSURL *)storeURL
{
    CoreDataLog;
    ///MARK:  展示迁移进度 防止用户使用这个App
    UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([MigrationViewController class]) bundle:nil];
    self.migrationVC = sb.instantiateInitialViewController;
    UIApplication *application = [UIApplication sharedApplication];
    UINavigationController *nc = (UINavigationController *)application.keyWindow.rootViewController;
    [nc presentViewController:self.migrationVC animated:YES completion:nil];
    
    ///MARK:  在后台执行迁移，所以他不会冻结UI, 这是一种可以展现进度给用户的方法
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        BOOL done = [self migrationStore:storeURL];
        if (done) {
            ///MARK:  当迁移完成，添加新的迁移存储空间
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = nil;
                self.store = [self.coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:nil error:&error];
                if (!self.store) {
                    NSLog(@"添加迁移的存储空间失败%@", error);
                    abort();
                } else {
                    NSLog(@"添加迁移的存储空间成功%@", self.store);
                }
                [self.migrationVC dismissViewControllerAnimated:NO completion:nil];
                self.migrationVC = nil;
            });
        }
    });
}

@end
