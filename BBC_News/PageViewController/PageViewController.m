//
//  PageViewController.m
//  CalendarTestProject
//
//  Created by Vitalii Todorovych on 15.07.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import "PageViewController.h"
#import "SimpleWebViewController.h"
#import "DPPageControl.h"
#import "MWFeedItem.h"
#import "ShareViewController.h"
#import "ZoomPopoverView.h"
#import "SharePopoverView.h"
#import "MWFeedItem.h"
#import "FeedData.h"
#import "NewsListViewController.h"
#import "CategoryItem.h"

#define SCROLLING_OFFSET_FOR_HIDDING    10
#define PAGE_WIGHT pageScrollView.frame.size.width
#define PAGE_HEIGHT pageScrollView.frame.size.height

@interface PageViewController () <UIPopoverControllerDelegate>
{
    UIButton *zoomTextButton;
}

@property (strong) NSArray *dataContent;

@end

@implementation PageViewController

- (void)dealloc
{
    for (UIView *subView in [pageScrollView subviews]) {
        [subView removeFromSuperview];
    }
    _pageContent = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithData:(NSArray*)data
{
    NSString *nibNameOrNil = @"PageViewController";
    if (nibNameOrNil && ![[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        NSString *iPadNibNameOrNil = [NSString stringWithFormat:@"%@_iPad",nibNameOrNil];
        if ([[NSBundle mainBundle] pathForResource:iPadNibNameOrNil ofType:@"nib"]) {
            nibNameOrNil = iPadNibNameOrNil;
        }
    }
    
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        [self setItems:data];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    pageScrollView.canCancelContentTouches = YES;
    if (!IS_IPAD) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updateUI];
    [self customizeUI];
    [self performSelectorOnMainThread:@selector(updatePageController) withObject:nil waitUntilDone:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([secondview.view superview]) {
        [secondview.view removeFromSuperview];
    }
}


- (void)updateNavBar{
    if(!IS_IPAD){
        UIButton *sectionsButton = [Helpers createButtonWithNormalImg:[UIImage imageNamed:@"sectionsBtnNorm"] highlightImg:[UIImage imageNamed:@"sectionsBtnHighlight"] delegate:self selector:@selector(onSections:)];
        UIBarButtonItem *sectionBtnItem = [[UIBarButtonItem alloc] initWithCustomView:sectionsButton];
        [self.navigationItem setLeftBarButtonItem:sectionBtnItem];
        
        zoomTextButton = [Helpers createButtonWithNormalImg:[UIImage imageNamed:@"zoomTextBtnNorm"] highlightImg:[UIImage imageNamed:@"zoomTextBtnHighlight"] delegate:self selector:@selector(onZoomTextBtn:)];
        _zoomBtnPressed = NO;
        UIButton *shareButton = [Helpers createButtonWithNormalImg:[UIImage imageNamed:@"shareBtnNorm"] highlightImg:[UIImage imageNamed:@"shareBtnHighlight"] delegate:self selector:@selector(onShareBtn:)];
        
        UIView *rightView = [Helpers createViewWithButtons:@[zoomTextButton, shareButton]];

        UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
        [self.navigationItem setRightBarButtonItem:rightBtnItem];
    }
}

- (void)customizeUI{
    if (!pageCounterView) {
        pageCounterView = [[DPPageControl alloc] initWithFrame:CGRectZero];
    }
    [pageCounterView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:pageCounterView];
    [self updatePageController];
}

- (void)setItems:(NSArray*)data{
    [self clearData];
    self.dataContent = data;
    [self updateUI];
}

- (void)clearData{
    for (UIViewController *viewController in _pageContent) {
        [viewController.view removeFromSuperview];
    }
    _currentPageIndex = 0;
    [pageScrollView setContentSize:CGSizeZero];
    _pageContent = nil;
}

- (void)clearUI{
    
    for (int i = 0; i < [self pageCount]; i++) {
        SimpleWebViewController *itemView = self.pageContent[i];
        [itemView.view removeFromSuperview];
        [itemView clearContent];
    }
}

- (void)updateUI{
    [self resizeRecipeView];
    [self updatePagesData];
    [self updatePageController];
    [self updateNavBar];
    if (self.feedData && self.feedData.categoryItem) {
        self.categoryTitleLbl.text = [self.feedData.categoryItem.title uppercaseString];
    }
}

- (void)updatePageController{
    [pageCounterView setNumberOfPages:[self pageCount]];
    float offset = ((IS_IPAD)?94:24);
        float widht = [self pageCount] * 8 + ([self pageCount]-1) * 6;
    if (!IS_IPAD) {
        widht = 150 - 24;
    }
    [pageCounterView setFrame:CGRectMake(self.view.frame.size.width - widht - offset, 0, widht, 24)];
    pageCounterView.currentPage = _currentPageIndex;
    [self.view addSubview:pageCounterView];
    [pageCounterView performSelector:@selector(updateDots) withObject:nil afterDelay:.1];
}

- (void)resizeRecipeView{
    [panelView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 25)];
    float yOffset = panelView.frame.origin.y + panelView.frame.size.height;

    [pageScrollView setFrame:CGRectMake(0, yOffset, self.view.frame.size.width, self.view.frame.size.height - yOffset)];
    id del = pageScrollView.delegate;
    [pageScrollView setDelegate:nil];
    pageScrollView.contentSize = CGSizeMake(PAGE_WIGHT * [self pageCount], PAGE_HEIGHT);
    [pageScrollView setDelegate:del];
    [self scrollToPageIndex:_currentPageIndex animation:NO];
    
    for (int i = 0; i < [self pageCount]; i++) {
        SimpleWebViewController *itemView = self.pageContent[i];
        CGRect itemViewFrame = CGRectMake(i * PAGE_WIGHT, 0, PAGE_WIGHT, PAGE_HEIGHT);
        [itemView.view setFrame:itemViewFrame];
        [pageScrollView addSubview:itemView.view];
        if (_currentPageIndex == i) {
            [itemView refresh];
        }
    }
}

#pragma mark page
- (void)preparePageWithIndex:(int)num{
    if ([self pageCount] <= num) {
        return;
    }
    //clearing data
    if (num > 1) {
        [[[self pageContent] objectAtIndex:num - 2] clearContent];
    }
    if (num + 2 < [[self pageContent] count]) {
        [[[self pageContent] objectAtIndex:num + 2] clearContent];
    }
    
    //loading data
    [[[self pageContent] objectAtIndex:num] loadData];
    if (num > 0) {
        [[[self pageContent] objectAtIndex:num - 1] loadData];
    }
    if ((num + 1 < [self pageCount])) {
        [[[self pageContent] objectAtIndex:num + 1] loadData];
    }
}

- (void)updatePagesData{
    for (int i = 0; i < [self pageCount]; i++) {
        SimpleWebViewController *itemView = self.pageContent[i];
        [itemView refresh];
    }
    [self scrollToPageIndex:[self  pageIndex] animation:NO];
}

- (int)pageCount{
    return [self.pageContent count];
}

- (NSArray*)pageContent{
    if (!_pageContent) {
        _pageContent = [[NSArray alloc] initWithArray:[self createViewsContent]];
    }
    return _pageContent;
}

- (NSArray*)createViewsContent{
    NSMutableArray *contaner = [NSMutableArray new];
    for (MWFeedItem* item in self.dataContent) {
        SimpleWebViewController *webView = [[SimpleWebViewController alloc] initWithNibName:@"SimpleWebViewController" bundle:nil];
        [webView setDelegate:self];
        [self.navigationController pushViewController:webView animated:YES];
        [webView setItemData:item];
        [webView loadData];
        [contaner addObject:webView];
    }
    return contaner;
}

- (void)scrollToPageIndex:(int)pageIndex animation:(BOOL)animated{
    _currentPageIndex = pageIndex;
    if (animated) {
        [UIView beginAnimations:@"PageScrolling" context:nil];
        [UIView setAnimationDuration:0.3];
    }
    pageScrollView.contentOffset = CGPointMake(pageScrollView.frame.size.width * _currentPageIndex, 0.0f);
    if (animated) {
        [UIView commitAnimations];
    }
    [self preparePageWithIndex:_currentPageIndex];
    [self pageDidChange];
}

- (int)pageIndex{
    return _currentPageIndex;
}

- (void)pageDidChange{
    [self updatePageController];
    
}

- (MWFeedItem*)currentItem{
    MWFeedItem* item = self.dataContent[_currentPageIndex];
    return item;
}

#pragma mark scroll view delegating
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
	CGPoint offset = pageScrollView.contentOffset;
    int num = (offset.x+pageScrollView.frame.size.width/2) / pageScrollView.frame.size.width;
    if (num != _currentPageIndex) {
        _currentPageIndex = num;
        [self preparePageWithIndex:num];
        [self pageDidChange];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.feedData, @"feedData",self.categoryItem, @"categoryItem" ,[NSNumber numberWithInt:_currentPageIndex], @"selectedIndex",@"1",@"selectedInPages", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FeedItemDidSelected" object:dict];
    }
}

#pragma mark - Actions

- (void)onSections:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onZoomTextBtn:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    _zoomBtnPressed = !_zoomBtnPressed;

    if(_zoomBtnPressed)
        [btn setBackgroundImage:[UIImage imageNamed:@"zoomTextBtnHighlight"] forState:UIControlStateNormal];
    else
        [btn setBackgroundImage:[UIImage imageNamed:@"zoomTextBtnNorm"] forState:UIControlStateNormal];
    
    if(IS_IPHONE){
        if ([secondview.view superview]) {
            [secondview.view removeFromSuperview];
            return;
        }
        if (!secondview) {
            secondview = [ZoomPopoverView new];
            secondview.view.autoresizesSubviews = YES;
        }
        [secondview.view setBackgroundColor:RGBCOLOR(105, 2, 8)];
        secondview.view.y = 0;
        [self.view addSubview:secondview.view];
    }else {
        [self showZoomPopover:sender];
    }
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    NewsListViewController *newsVC = self.delegate;
    _zoomBtnPressed = NO;
    [newsVC.zoomTextButton setBackgroundImage:[UIImage imageNamed:@"zoomTextBtnNorm"] forState:UIControlStateNormal];
    return YES;
}


- (void)onShareBtn:(id)sender
{
    if(IS_IPHONE)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Email", @"Twitter", @"Facebook", @"Copy web link", nil];
        
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [actionSheet showInView:self.view];
    }else{
        [self showSharePopover:sender];
    }
}

#pragma mark - ActionSheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:     // Email
        {
            [self showMailForm];
        }
            break;
            
        case 1:     // Twitter
        {
            [self twitterPost];
        }
            break;
        case 2:     // Facebook
        {
            [self facebookPost];
        }
            break;
            
        case 3:     // Copy web link
        {
            [UIPasteboard generalPasteboard].string = [self currentItem].title;
        }
            break;
    }
}


- (void)mailPost{
    
}

- (void)facebookPost{
    if (!shareViewController) {
        shareViewController = [ShareViewController new];
    }
    MWFeedItem *item = [self currentItem];
    [shareViewController setDelegateViewController:((UIViewController*)self.delegate).navigationController];
    [shareViewController postFacebookItem:item];
}

- (void)twitterPost{
    if (!shareViewController) {
        shareViewController = [ShareViewController new];
    }
    MWFeedItem *item = [self currentItem];
    [shareViewController setDelegateViewController:((UIViewController*)self.delegate).navigationController];
    [shareViewController postTwitterItem:item];
}

- (void)showPopover:(UIViewController *)popoverView fromButton:(UIButton *)senderBtn
{
    popover = [[UIPopoverController alloc] initWithContentViewController:popoverView];
    
    CGRect frame = [senderBtn convertRect:senderBtn.frame toView:self.view];
    
    frame.origin.y += frame.size.height / 2;
    [popover setPopoverContentSize:CGSizeMake(popoverView.view.width, popoverView.view.height)];
    [popover presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];

    if([popoverView isKindOfClass:[ZoomPopoverView class]])
        popover.delegate = self;    
}

- (void)showSharePopover:(id)sender
{
    if (!sharePopover) {
        sharePopover = [SharePopoverView new];
    }
    [sharePopover setDelegate:self];
    [self showPopover:sharePopover fromButton:sender];
}

- (void)showZoomPopover:(id)sender{
    if (!secondview) {
        secondview = [ZoomPopoverView new];
        
    }
    [self showPopover:secondview fromButton:sender];
}

- (void)scrollDisable
{
    pageScrollView.scrollEnabled = NO;
}

- (void)scrollEnabled
{
    pageScrollView.scrollEnabled = YES;
}

- (void)showMailForm{
    if ([MFMailComposeViewController canSendMail]) {
        // Show the composer
    } else {
        // Handle the error
    }
    MWFeedItem *feedItem = self.feedData.items[_currentPageIndex];
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    NSString *theme = [NSString stringWithFormat:@"I saw this story on the Vagus News %@ App and thought you should see it:\
                       \n\n%@\
                       \n\n%@\
                       \n\n%@\
                       \n\n\n** Disclaimer **\
                       Vagus is not responsible for the content of this e-mail, and anything written in this e-mail does not necessarily reflect the Vagus views or opinions. Please note that neither the e-mail address nor name of the sender have been verified.",(IS_IPAD)?@"iPad":@"iPhone",feedItem.link,feedItem.title,feedItem.summary];
    [controller setSubject:[NSString stringWithFormat:@"Vagus News: %@",feedItem.title]];
    [controller setMessageBody:theme isHTML:NO];
    if (controller) [self presentViewController:controller animated:YES
                                     completion:^{
                                         
                                     }];
}


- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self updateUI];
    pageScrollView.contentOffset = CGPointMake(pageScrollView.frame.size.width * _currentPageIndex, 0.0f);
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration{

}


@end
