//
//  CoreDataHelper.h
//  CoreData
//
//  Created by Danyow.Ed on 2017/1/27.
//  Copyright © 2017年 Danyow.Ed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataHelper : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext       *context;
@property (nonatomic, strong, readonly) NSManagedObjectModel         *model;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *coordinator;
@property (nonatomic, strong, readonly) NSPersistentStore            *store;

+ (instancetype)shareHelper;
- (void)setupCoreData;
- (void)saveContext;

@end
