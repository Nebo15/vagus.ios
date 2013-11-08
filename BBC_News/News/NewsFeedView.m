//
//  NewsFeedView.m
//  BBC_News
//
//  Created by Vitalii Todorovych on 15.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import "NewsFeedView.h"
#import "ALImageView.h"
#import "DataStoreAbstract.h"
#import "RSSNewsStoreController.h"
#import "NewsItemView.h"
#import "MWFeedItem.h"
#import "FeedData.h"
#import "CategoryItem.h"

#define TOP_OFFSET 0
#define BOTTOM_OFFSET 7
#define LEFT_OFFSET 6
#define RIGHT_OFFSET 6
#define MIDLE_OFFSET 8
#define ITEM_WIDHT 128

@interface NewsFeedView()


@end

@implementation NewsFeedView

- (id)initWithData:(FeedData*)item
{
    self = [super initWithNibName:@"NewsFeedView" bundle:nil];
    if (self) {
        self.feedData = item;
        
    }
    return self;
}

- (void)createUI{
    int index = 0;
    if (!queue)queue = [[NSOperationQueue alloc] init];

    
    if (self.feedData.categoryItem.title) {
        [self.titleLbl setText:self.feedData.categoryItem.title];
    }
    
    [self.scrollImagesView setContentSize:CGSizeMake(LEFT_OFFSET + RIGHT_OFFSET + ([self.feedData.items count] * (ITEM_WIDHT + MIDLE_OFFSET)) - MIDLE_OFFSET, 100)];
    for (MWFeedItem *feedItem in self.feedData.items) {
        float xOffset = LEFT_OFFSET + index * (ITEM_WIDHT + MIDLE_OFFSET);
        NewsItemView *itemView = [[NewsItemView alloc] initWithFeedItem:feedItem];
        [itemView.imageView setImageCustom:nil];
        [itemView setBackgroundColor:[UIColor clearColor]];
        [itemView setDelegate:self];
        [self.scrollImagesView addSubview:itemView];
        CGRect itemFrame = itemView.frame;
        itemFrame.origin.x = xOffset;
        itemFrame.origin.y = TOP_OFFSET;
        [itemView setFrame:itemFrame];
        index++;
        [queue addOperationWithBlock:^{
//            if ( itemView.frame.origin.x < self.scrollImagesView.contentOffset.x + self.scrollImagesView.frame.size.width+itemView.frame.size.width*2) {
                [itemView loadData];
//            }
        }];
    }
}

- (void)clearData{
    for (NewsItemView *view in [self.scrollImagesView subviews]) {
        [view setDelegate:nil];
        [view.imageView setImageCustom:nil];
        [view removeFromSuperview];
    }
}

- (void)itemDidSelected:(MWFeedItem*)itemView{
    
    int i = 0;
    for (MWFeedItem* item in self.feedData.items) {
        if ([item.identifier isEqualToString:itemView.identifier]) {
            break;
        }
        i++;
    }
//    [self scrollToItemWithIndex:i];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.feedData, @"feedData",self.catItem, @"categoryItem",[NSNumber numberWithInt:i], @"selectedIndex",itemView.identifier, @"identifier", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FeedItemDidSelected" object:dict];
}

- (void)scrollToItemWithIndex:(int)index{
    float xOffset = index * (ITEM_WIDHT + MIDLE_OFFSET);
    if (xOffset < self.scrollImagesView.contentSize.width - self.scrollImagesView.frame.size.width) {
        [UIView animateWithDuration:.3 animations:^{
            [self.scrollImagesView setContentOffset:CGPointMake(xOffset, self.scrollImagesView.contentOffset.y)];
        }];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    for (NewsItemView *itemView in scrollView.subviews) {
        if ( itemView.frame.origin.x < scrollView.contentOffset.x + scrollView.frame.size.width+itemView.frame.size.width*2) {
            [queue addOperationWithBlock:^{
                    [itemView loadData];
            }];
        }else{
            [itemView clearData];

        }
    }

}

- (void)dealloc
{
    [self clearData];
    NSLog(@"dealloc NewsFeedView");
}

@end
