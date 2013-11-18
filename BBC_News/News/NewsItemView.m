//
//  NewsItemView.m
//  BBC_News
//
//  Created by Vitalii Todorovych on 15.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import "NewsItemView.h"
#import "ALImageView.h"
#import "MWFeedItem.h"
#import "CategoryItem.h"
#import "NewsFeedView.h"
#import "FeedData.h"

@interface NewsItemView()

@property (strong, nonatomic) IBOutlet UIView *selectionView;

@end

@implementation NewsItemView

- (void)dealloc
{
    [self clearData];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFeedItem:(MWFeedItem*)feed
{
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"NewsItemView" owner:self options:nil] objectAtIndex:0];
        self.feedItem = feed;
    }
    return self;
}


- (void)didMoveToSuperview{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkStatus:) name:@"FeedItemDidSelected" object:nil];
    [self.titleLbl setText:self.feedItem.title];
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)loadData{
    if (!self.imageView.isLoaded) {
        [self.imageView loadWithURL:[NSURL URLWithString:self.feedItem.thumbnail]];
    }
    [self.titleLbl setText:self.feedItem.title];
}

- (void)clearData{
    [self.imageView setImageCustom:nil];
    self.imageView.isLoaded = NO;
}


- (IBAction)didSelectView:(id)sender{
    [[NSUserDefaults standardUserDefaults] setObject:self.feedItem.identifier forKey:@"LastItem"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemDidSelected:)]) {
        [self.delegate performSelector:@selector(itemDidSelected:) withObject:self.feedItem];
    }else{
    }
}

- (void)checkStatus:(NSNotification *)notification{
    NSDictionary *dictData = notification.object;
//    CategoryItem *categoryItem = [dictData objectForKey:@"categoryItem"];
    FeedData *feedData = [dictData objectForKey:@"feedData"];
    int index = [[dictData objectForKey:@"selectedIndex"] integerValue];
    NSString *identifier = ((MWFeedItem*)feedData.items[index]).identifier;
    
    [_selectionView setBackgroundColor:[UIColor clearColor]];
//    if (categoryItem == self.delegate.feedData.categoryItem) {
        if ([self.feedItem.identifier isEqualToString:identifier]) {
            [_selectionView setBackgroundColor:DEFAULT_COLOR];
            [self.delegate scrollToItemWithIndex:index];
        }
//    }
}


@end
