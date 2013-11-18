//
//  NewsFeedCell.h
//  BBC_News
//
//  Created by Vitalii Todorovych on 15.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CategoryItem;
@class NewsFeedView;
@class FeedData;
@interface NewsFeedCell : UITableViewCell{
    NewsFeedView *newsFeedView;
    NSOperationQueue *queue;
}

@property (nonatomic,strong) CategoryItem *item;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UIImageView *arrow;
@property (weak, nonatomic) IBOutlet UIImageView *separateImageView;
+ (UINib *)nib;


- (void)createUIWithFeedData:(FeedData*)feedData;
- (void)hideView;
- (void)clearView;

@end
