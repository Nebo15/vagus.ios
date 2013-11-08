//
//  NewsFeedCell.m
//  BBC_News
//
//  Created by Vitalii Todorovych on 15.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import "NewsFeedCell.h"
#import "NewsFeedView.h"
#import "CategoryItem.h"
#import "NewsFeedView.h"
#import "FeedData.h"

@implementation NewsFeedCell

- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    if (editing) {
        [self hideView];
    }else{
        [newsFeedView createUI];
    }
}

- (void)createUIWithFeedData:(FeedData*)feedData{
    if (feedData != newsFeedView.feedData) {
        if (!newsFeedView) {
            newsFeedView = [[NewsFeedView alloc] initWithData:feedData];
        }
        [feedData setDelegate:self];
        [newsFeedView setCatItem:self.item];
        [newsFeedView setFeedData:feedData];
        if ([feedData isLoadet]) {
            [newsFeedView createUI];
        }else{
            [feedData loadData];
        }
    }
        [self.contentView addSubview:newsFeedView.view];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
    
    [self.titleLbl setHidden:(self.isEditing)?NO:YES];
    [self.separateImageView setHidden:(self.isEditing)?NO:YES];
    float yOffset = 0;
    if (([self.item.isFavorite isEqualToString:@"1"] ||
         [self.item.defaultStr isEqualToString:@"1"]) && !self.isEditing) {
        [self.titleLbl setHidden:NO];
        yOffset = 27;
        self.titleLbl.y = 3;
    }else{
        self.titleLbl.y = 13;
    }
    [newsFeedView.view setFrame:CGRectMake(0, yOffset, self.contentView.frame.size.width, 134)];
    [newsFeedView.scrollImagesView setFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 134)];
//    [newsFeedView updateUI];
    
}

- (void)clearView{
    [newsFeedView clearData];
    [newsFeedView.view removeFromSuperview];
    newsFeedView = nil;
}

- (void)hideView{
    [newsFeedView clearData];
    [newsFeedView.view removeFromSuperview];
}

#pragma mark Feed data delegate

- (void)feedDataDidFinishLoad:(FeedData*)feedData{
//    [self createUIWithFeedData:feedData];
    [newsFeedView setFeedData:feedData];
    [newsFeedView createUI];
}

- (void)dealloc
{
NSLog(@"dealloc NewsFeedCell");
}

@end
