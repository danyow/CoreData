//
//  LocationAtShop+CoreDataProperties.m
//  CoreData
//
//  Created by Danyow.Ed on 2017/2/8.
//  Copyright © 2017年 Danyow.Ed. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "LocationAtShop+CoreDataProperties.h"

@implementation LocationAtShop (CoreDataProperties)

+ (NSFetchRequest<LocationAtShop *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"LocationAtShop"];
}

@dynamic aisle;
@dynamic items;

@end
