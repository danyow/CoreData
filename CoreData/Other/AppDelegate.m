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
    Unit *kg = [NSEntityDescription insertNewObjectForEntityForName:@"Unit" inManagedObjectContext:self.helper.context];
    Item *oranges = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:self.helper.context];
    Item *bananas = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:self.helper.context];
    kg.name = @"Kg";
    oranges.name = @"Oranges";
    bananas.name = @"Bananas";
    oranges.quantity = 1;
    bananas.quantity = 4;
    oranges.listed = YES;
    bananas.listed = YES;
    oranges.unit = kg;
    bananas.unit = kg;
    NSLog(@"插入模型： %.1f%@ %@", oranges.quantity, oranges.unit.name, oranges.name);
    NSLog(@"插入模型： %.1f%@ %@", bananas.quantity, bananas.unit.name, bananas.name);
    [self.helper saveContext];
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
