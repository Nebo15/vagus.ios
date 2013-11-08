//
//  NewsItemView.h
//  BBC_News
//
//  Created by Vitalii Todorovych on 15.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALImageView;
@class MWFeedItem;
@class NewsFeedView;
@interface NewsItemView : UIControl{
    UIView *rootView;
}

@property (nonatomic, weak) NewsFeedView *delegate;
@property (nonatomic, strong) MWFeedItem *feedItem;
@property (weak, nonatomic) IBOutlet ALImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;

- (IBAction)didSelectView:(id)sender;

- (id)initWithFeedItem:(MWFeedItem*)feed;

- (void)loadData;
- (void)clearData;

@end
