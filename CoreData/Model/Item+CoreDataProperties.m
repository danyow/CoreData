//
//  Item+CoreDataProperties.m
//  CoreData
//
//  Created by Danyow on 2017/2/5.
//  Copyright © 2017年 Danyow.Ed. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "Item+CoreDataProperties.h"

@implementation Item (CoreDataProperties)

+ (NSFetchRequest<Item *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Item"];
}

@dynamic name;
@dynamic quantity;
@dynamic photoData;
@dynamic listed;
@dynamic collected;

@end
