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
    CoreDataLog;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
    [request setFetchLimit:50];
    NSError *error = nil;
    NSArray *fectchObjects = [self.helper.context executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"失败了%@", error);
    } else {
        for (Unit *unit in fectchObjects) {
            NSLog(@"迁移数据成功 找到了-->%@", unit.name);
        }
    }
}

#pragma mark -  life cycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

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
