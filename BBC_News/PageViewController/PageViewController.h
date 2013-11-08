//
//  PageViewController.h
//  CalendarTestProject
//
//  Created by Vitalii Todorovych on 15.07.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseNavigationController.h"
#import <MessageUI/MFMailComposeViewController.h>

@class DPPageControl;
@class ShareViewController;
@class SharePopoverView;
@class ZoomPopoverView;
@class FeedData;
@class CategoryItem;
@class MWFeedItem;
@interface PageViewController : BaseNavigationController <MFMailComposeViewControllerDelegate,UINavigationControllerDelegate, UIScrollViewDelegate, UIActionSheetDelegate>
{
    IBOutlet UIScrollView *pageScrollView;
    IBOutlet DPPageControl *pageCounterView;
    ShareViewController *shareViewController;
    
    NSArray *_pageContent;
    IBOutlet UIView *panelView;
    SharePopoverView *sharePopover;
    UIPopoverController *popover;
    ZoomPopoverView *secondview;
    NSOperationQueue *queue;

}

@property (weak, nonatomic) IBOutlet UILabel *categoryTitleLbl;
@property (strong, nonatomic) FeedData *feedData;
@property (strong, nonatomic) CategoryItem *categoryItem;
@property (nonatomic,weak) id delegate;
@property int currentPageIndex;
@property (assign, nonatomic) BOOL zoomBtnPressed;

- (id)initWithData:(NSArray*)data;

- (void)scrollToPageIndex:(int)pageIndex animation:(BOOL)animated;
- (void)resizeRecipeView;
- (void)setItems:(NSArray*)data;
- (void)updateUI;

- (void)scrollDisable;
- (void)scrollEnabled;
- (void)clearData;
- (void)clearUI;
- (void)showMailForm;

@end
