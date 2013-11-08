//
//  NewsListViewController.h
//  BBC_News
//
//  Created by Vitalii Todorovych on 15.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import "TableViewController.h"
#import "SharePopoverView.h"
#import <MessageUI/MFMailComposeViewController.h>

#define TITLE_SECTION_HEIGHT 50
#define FAVORITES_CELL_HEIGHT 162
#define EXTENDED_CELL_HEIGHT 134

@class TTTAttributedLabel;
@class ZoomPopoverView;
@class NewsFeedView;
@class PageViewController;
@class FooterView;
@class FeedData;
@class LatestViewController;
@interface NewsListViewController : TableViewController <MFMailComposeViewControllerDelegate, UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSMutableDictionary *feedDataContent;
    NSMutableArray *items;
    
    PageViewController *pageViewController;
    
    NewsFeedView *newsFeedView;
    ZoomPopoverView *secondview;
    FooterView *footerView;
    
    BOOL isItemShoved;
    UIRefreshControl *refreshControl;
    UIImagePickerController *imagePickerController;
    UIPopoverController* popOverController;
    
    NSDictionary *quickLatestNewsDict;
    FeedData *quikfeedData;
    //    NSTimer
    
    NSOperationQueue *queue;
    
    int loadingItemsIndex;
}

@property (strong, nonatomic) LatestViewController *latestNewsView;
@property (strong, nonatomic) UIButton *zoomTextButton;

- (void)showMailForm;
- (void)showPhotoPiker:(id)sender;
- (void)showNewsDetailWithIdentifier:(NSString *)identifier;

- (void)showLatestView;
- (void)hideLatestView;

- (BOOL)newsHasWithIdentifier:(NSString *)identifier;
- (BOOL)hasNewsDetailWithIdentifier:(NSString *)identifier;

@end
