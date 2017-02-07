//
//  AppDelegate.m
//  CoreData
//
//  Created by Danyow.Ed on 2017/1/27.
//  Copyright © 2017年 Danyow.Ed. All rights reserved.
//

#import "AppDelegate.h"
#import "CoreDataHelper.h"
#import "Item+CoreDataProperties.h"
#import "Unit+CoreDataProperties.h"
@interface AppDelegate ()

@property (nonatomic, strong) CoreDataHelper *helper;

@end

@implementation AppDelegate

#pragma mark -  Demo method

- (void)demo
{
    NSLog(@"在删除单位对象之前");
    [self showUnitAndItemCount];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"name == %@", @"Kg"];
    [request setPredicate:filter];
    NSArray *kgUnit = [self.helper.context executeFetchRequest:request error:nil];
    for (Unit *unit in kgUnit) {
        [self.helper.context deleteObject:unit];
        NSLog(@"一个Kg单位对象已经删除完毕");
    }
    NSLog(@"在删除单位对象之后");
    [self showUnitAndItemCount];
    [self.helper saveContext];
}

- (void)showUnitAndItemCount
{
    ///MARK:  列出多少个Items在数据库里面
    NSFetchRequest *items = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    NSError *itemsError = nil;
    NSArray *fetchedItems = [self.helper.context executeFetchRequest:items error:&itemsError];
    if (!fetchedItems) {
        NSLog(@"%@", itemsError);
    } else {
        NSLog(@"找到了%lu个Item", fetchedItems.count);
    }
    
    ///MARK:  列出多少个Units在数据库里面
    NSFetchRequest *units = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
    NSError *unitsError = nil;
    NSArray *fetchedUnits = [self.helper.context executeFetchRequest:units error:&unitsError];
    if (!fetchedUnits) {
        NSLog(@"%@", unitsError);
    } else {
        NSLog(@"找到了%lu个Unit", fetchedUnits.count);
    }
}

#pragma mark -  life cycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    NSLog(@"%@", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES));
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{

}

/**
    将要进入后台的时候调用
 */
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.helper saveContext];
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{

}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    CoreDataLog;
    [self demo];
}

/**
    将要被终止程序的时候调用
 */
- (void)applicationWillTerminate:(UIApplication *)application
{
    [self.helper saveContext];
}


- (CoreDataHelper *)helper
{
    if (!_helper) {
        _helper = [CoreDataHelper shareHelper];
        [_helper setupCoreData];
    }
    return _helper;
}

@end
