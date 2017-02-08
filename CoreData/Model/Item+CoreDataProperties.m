//
//  Item+CoreDataProperties.m
//  CoreData
//
//  Created by Danyow.Ed on 2017/2/8.
//  Copyright © 2017年 Danyow.Ed. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "Item+CoreDataProperties.h"

@implementation Item (CoreDataProperties)

+ (NSFetchRequest<Item *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Item"];
}

@dynamic collected;
@dynamic listed;
@dynamic name;
@dynamic photoData;
@dynamic quantity;
@dynamic unit;
@dynamic locationAtHome;
@dynamic locationAtShop;

@end
