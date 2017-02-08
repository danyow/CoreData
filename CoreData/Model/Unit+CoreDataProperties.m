//
//  Unit+CoreDataProperties.m
//  CoreData
//
//  Created by Danyow.Ed on 2017/2/8.
//  Copyright © 2017年 Danyow.Ed. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "Unit+CoreDataProperties.h"

@implementation Unit (CoreDataProperties)

+ (NSFetchRequest<Unit *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Unit"];
}

@dynamic name;
@dynamic items;

@end
