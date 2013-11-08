//
//  FeedData.m
//  BBC_News
//
//  Created by Vitalii Todorovych on 20.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import "FeedData.h"
#import "RSSNewsStoreController.h"
#import "CategoryItem.h"
#import "CategoryItem.h"

@interface FeedData ()

@end

@implementation FeedData

- (id)initWithCategoryItem:(CategoryItem*)catItem
{
    
    self = [super init];
    if (self) {
        self.categoryItem = catItem;
    }
    return self;
}

//Needs to be recolled in the subcalsses
- (void)createModel{
    if (!self.dataModel) {
        self.dataModel = [[BaseDataModel alloc] initWithDelegate:self];
        self.dataModel.dataStore = [[RSSNewsStoreController alloc] initWithDataModelDelegate:self.dataModel viewControllerDelegate:self];
    }
}

- (void)updateData{
    [self loadData];
}

- (void)loadData{
    if (!self.items) {
        if (self.categoryItem.feed_url) {
            [self.dataModel.dataStore getNewsWithURL:self.categoryItem.feed_url];
        }
    }
}

- (void)modelDidFinishLoad:(id)data {
//    [super modelDidFinishLoad:data];
    if ([data count] > 0) {
        self.items = [NSArray arrayWithArray:data];
    }
        if (self.delegate && [self.delegate respondsToSelector:@selector(feedDataDidFinishLoad:)]) {
            [self.delegate performSelector:@selector(feedDataDidFinishLoad:) withObject:self];
        }
}
-(void)modelDidFailLoadWithError:(NSError*)error;
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(feedDataDidFinishLoad:)]) {
        [self.delegate performSelector:@selector(feedDataDidFinishLoad:) withObject:self];
    }
}

- (BOOL) isLoadet{
        return ((self.items)?YES:NO);
}
    
    @end