//
//  DataStoreAbstract.m
//  BBC_News
//
//  Created by Vitalii Todorovych on 26.05.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import "DataStoreAbstract.h"

@implementation DataStoreAbstract

- (id)initWithDataModelDelegate:(id)delegateModel viewControllerDelegate:(id)delegateViewController
{
    self = [super init];
    if (self) {
        self.dataModel = delegateModel;
        self.viewControllerDelegate = delegateViewController;
    }
    return self;
}


- (void)getNewsWithURL:(NSString*)url{}
- (void)getNewsList{}
- (void)getLatestNewsList{}

+ (NSArray*)getSelected{return nil;}
+ (NSArray*)getFavorites{return nil;}
+ (BOOL)addFavorites:(NSString*)newsTitle{return NO;}
+ (BOOL)removeFavorites:(NSString*)newsTitle{return NO;}
+ (BOOL)addToListName:(NSString*)listName withDataStr:(NSString*)newsTitle{return NO;}
+ (BOOL)removeFromListName:(NSString*)listName withDataStr:(NSString*)newsTitle{return NO;}

@end
