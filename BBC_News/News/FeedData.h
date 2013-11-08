//
//  FeedData.h
//  BBC_News
//
//  Created by Vitalii Todorovych on 20.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import "BaseDataModelViewController.h"

@protocol FeedDataProtocol <NSObject>

- (void)feedDataDidFinishLoad:(id)data;

@end

@class CategoryItem;
@interface FeedData : BaseDataModelViewController

@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) CategoryItem *categoryItem;

- (id)initWithCategoryItem:(CategoryItem*)catItem;
- (void)loadData;
- (BOOL) isLoadet;

@property (weak) id delegate;
@end
