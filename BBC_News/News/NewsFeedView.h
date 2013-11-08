//
//  NewsFeedView.h
//  BBC_News
//
//  Created by Vitalii Todorovych on 15.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseDataModelViewController.h"

@class FeedData;
@class CategoryItem;
@interface NewsFeedView : BaseDataModelViewController <UIScrollViewDelegate>{
    NSArray *views;
    NSOperationQueue *queue;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollImagesView;
@property (nonatomic,strong) UIView *rootView;
@property (strong, nonatomic) FeedData *feedData;
@property (strong, nonatomic) CategoryItem *catItem;

- (id)initWithData:(FeedData*)item;
- (void)scrollToItemWithIndex:(int)index;
- (void)createUI;
- (void)clearData;

@end
