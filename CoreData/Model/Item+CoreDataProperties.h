//
//  Item+CoreDataProperties.h
//  CoreData
//
//  Created by Danyow on 2017/2/5.
//  Copyright © 2017年 Danyow.Ed. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "Item+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Item (CoreDataProperties)

+ (NSFetchRequest<Item *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) float quantity;
@property (nullable, nonatomic, retain) NSData *photoData;
@property (nonatomic) BOOL listed;
@property (nonatomic) BOOL collected;

@end

NS_ASSUME_NONNULL_END
