//
//  Location+CoreDataProperties.m
//  CoreData
//
//  Created by Danyow.Ed on 2017/2/8.
//  Copyright © 2017年 Danyow.Ed. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "Location+CoreDataProperties.h"

@implementation Location (CoreDataProperties)

+ (NSFetchRequest<Location *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Location"];
}

@dynamic summary;

@end
