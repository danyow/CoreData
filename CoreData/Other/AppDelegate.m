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

@interface AppDelegate ()

@property (nonatomic, strong) CoreDataHelper *helper;

@end

@implementation AppDelegate

#pragma mark -  Demo method

- (void)demo
{
    CoreDataLog;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    
    /** 排序 */
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [request setSortDescriptors:@[sort]];
    
    /** 谓词 */
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"name == %@", @"Coffee"];
    [request setPredicate:filter];
    
    NSArray *fetchedObjects = [self.helper.context executeFetchRequest:request error:nil];
    for (Item *item in fetchedObjects) {
        NSLog(@"找到了已经存储对象%@", item.name);
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
