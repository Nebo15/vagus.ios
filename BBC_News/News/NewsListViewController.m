//
//  NewsListViewController.m
//  BBC_News
//
//  Created by Vitalii Todorovych on 15.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import "NewsListViewController.h"
#import "OnlineStoreController.h"
#import "NewsFeedView.h"
#import "NewsFeedCell.h"
#import "Helpers.h"
#import "MWFeedItem.h"
#import "SimpleWebViewController.h"
#import "PageViewController.h"
#import "ZoomPopoverView.h"
#import "DragViewController.h"
#import "SharePopoverView.h"
#import "CategoryItem.h"
#import "TableHeadView.h"
#import "AppDelegate.h"
#import "FeedData.h"
#import "TTTAttributedLabel.h"
#import "NSNumber+Interaction.h"
#import "FooterView.h"
#import "NSData+Base64.h"
#import "LatestViewController.h"

#define TABLE_HEIGHT (self.view.height - self.navigationController.navigationBar.frame.size.height)

@interface NewsListViewController () <UIPopoverControllerDelegate>
@property (strong, nonatomic) DragViewController *dragVC;
@end

@implementation NewsListViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dragViewOpened:) name:DragViewOpenedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dragViewClosed:) name:DragViewClosedNotification object:nil];
}

- (void)loadData{
    if (!self.dataModel.isLoaded) {
        [self.dataModel.dataStore getNewsList];
    }
}

- (void)pullItems:(NSArray*)itemsAr toMutableArray:(NSMutableArray*)mAr{
    NSArray* tagsArray = @[@"?kategori=manset+yanmanset+manset",@"?tag=Ankara",@"?tag=direnis+eylem+protest",@"?tag=Ortadoğu",@"?tag=bdp+kck+pkk",@"?tag=Video",@"?tag=Avam",@"?tag=hayatın-içinden",@"?tag=Kültur-Sanat",@"?tag=Bilim-Teknoloji",@"?tag=Sağlık",@"?tag=Spor"];
    for (int i = 0; i < [itemsAr count]; i++) {
        @try {
            CategoryItem *categoryItem = [[CategoryItem alloc]initWithTitle:itemsAr[i]
                                                                   feed_url:[NSString stringWithFormat:@"http://vagus.tv/feed/atom/%@",tagsArray[i]]];
//            if ([dict objectForKey:@"defaultStr"]) {
//                categoryItem.defaultStr = [dict objectForKey:@"defaultStr"];
//            }
//            if ([dict objectForKey:@"movable"]) {
//                categoryItem.movable = [dict objectForKey:@"movable"];
//            }
            [mAr addObject:categoryItem];
        }
        @catch (NSException *exception) {
            NSLog(@"Error during parse category items");
        }
    }
}

- (void)modelDidFinishLoad:(id)data {
    //if (data[@"feeds"]) {
      //  self.data = [NSArray arrayWithArray:data[@"feeds"]];
        items = [NSMutableArray new];
        NSArray* tagsArray = @[@"Manşet",@"Ankara Havası",@"Derin Siyaset",@"Ortadoğu",@"Kürt Dosyası",@"Video",@"Avam Kamerası",@"Hayatın İçinden",@"Kültur-Sanat",@"Bilim-Teknoloji",@"Sağlık",@"Spor"];
        [self pullItems:tagsArray toMutableArray:items];
        [self sortItems];
  //  }
    loadingItemsIndex = 0;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [refreshControl endRefreshing];
    [self.table reloadData];
    [super modelDidFinishLoad:nil];
    [self performSelector:@selector(loadItems) withObject:nil afterDelay:2];
    if (IS_IPAD) {
        [self performSelector:@selector(loadLatestItem) withObject:nil afterDelay:1];
    }
}

//loading feed content (news items)
- (void)loadItems{
    for (int i = loadingItemsIndex; i < [items count]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
        if (!feedDataContent) {
            feedDataContent = [NSMutableDictionary new];
        }
        CategoryItem *catItem = items[indexPath.section];
        FeedData *feedData = [feedDataContent objectForKey:catItem.title];
        if (!feedData) {
            feedData = [[FeedData alloc] initWithCategoryItem:catItem];
            @synchronized(feedDataContent){
                [feedDataContent setValue:feedData forKey:feedData.categoryItem.title];
            }
            [feedData setDelegate:self];
            [feedData loadData];
            return;
        }
        loadingItemsIndex++;
    }
    [self createLatestPanel];
}

- (void)feedDataDidFinishLoad:(FeedData*)feedData{
    loadingItemsIndex++;
    [self loadItems];
}

//loadind last selected item for Web page
- (void)loadLatestItem{
    FeedData *feedData = [self createDataForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:feedData, @"feedData",feedData.categoryItem, @"categoryItem",[NSNumber numberWithInt:0], @"selectedIndex",@"1",@"noClose", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FeedItemDidSelected" object:dict];
    [self updateUI];
}

// sortion content data
- (void)sortItems{
    NSMutableArray *favorites = [[OnlineStoreController getFavorites] mutableCopy];
    NSMutableArray *selectedItems = [[OnlineStoreController getSelected] mutableCopy];
    for (CategoryItem *item in items) {
        for (NSString *favoritesName in favorites) {
            if ([item.title isEqualToString:favoritesName]) {
                item.isFavorite = @"1";
                [favorites removeObject:favoritesName];
                break;
            }
        }
        for (NSString *selectedName in selectedItems) {
            if ([item.title isEqualToString:selectedName]) {
                item.isSelected = @"1";
                [selectedItems removeObject:selectedName];
                break;
            }
        }
    }
    [items sortUsingDescriptors:[NSArray arrayWithObjects:
                                 [NSSortDescriptor sortDescriptorWithKey:@"defaultStr" ascending:NO],
                                 [NSSortDescriptor sortDescriptorWithKey:@"isFavorite" ascending:NO], nil]];
}

- (FeedData*)createDataForCellAtIndexPath:(NSIndexPath*)indexPath{
    if (!feedDataContent) {
        feedDataContent = [NSMutableDictionary new];
    }
    CategoryItem *catItem = items[indexPath.section];
    FeedData *feedData = [feedDataContent objectForKey:catItem.title];
    if (!feedData) {
        feedData = [[FeedData alloc] initWithCategoryItem:catItem];
    }
    @synchronized(feedDataContent){
        [feedDataContent setValue:feedData forKey:catItem.title];
    }
    return feedData;
}

#pragma mark table view delegating
- (NSString*) tableView: (UITableView*)tableView cellIdentifierForRowAtIndexPath: (NSIndexPath*)indexPath {
	return @"NewsFeedCell";
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(NewsFeedCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell clearView];
}

- (void) configureCell:(NewsFeedCell*)theCell forRowAtIndexPath: (NSIndexPath*)indexPath {
    CategoryItem *catItem = items[indexPath.section];
    [theCell setItem:catItem];
    [theCell.titleLbl setText:[catItem.title uppercaseString]];
    [theCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if ([catItem.isSelected isEqualToString:@"1"] || [catItem.isFavorite isEqualToString:@"1"] ||
        [catItem.defaultStr isEqualToString:@"1"]) {
        FeedData *feedData = [feedDataContent objectForKey:catItem.title];
        if (!feedData) {
            feedData = [self createDataForCellAtIndexPath:indexPath];
        }
        [theCell createUIWithFeedData:feedData];
    }else{
        [theCell hideView];
    }
    [theCell setBackgroundColor:[UIColor clearColor]];
}

- (BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSInteger) numberOfSectionsInTableView: (UITableView*)tableView {
    return [items count];
}

- (NSInteger) tableView: (UITableView*)tableView numberOfRowsInSection: (NSInteger)section {
    return 1;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.table.isEditing) {
        return 50;
    }
    CategoryItem *item = items[indexPath.section];
    if ([item.isFavorite isEqualToString:@"1"] ||
        [item.defaultStr isEqualToString:@"1"]) {
        return FAVORITES_CELL_HEIGHT;
    }else if ([item.isSelected isEqualToString:@"1"]) {
        return EXTENDED_CELL_HEIGHT;
    }
    return 0;
}

- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.table.isEditing) {
        return 0;
    }
    CategoryItem *item = items[section];
    if ([item.isFavorite isEqualToString:@"1"] ||
        [item.defaultStr isEqualToString:@"1"]) {
        return 0;
    }
    return TITLE_SECTION_HEIGHT;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CategoryItem *item = items[section];
    TableHeadView *headView = [[[NSBundle mainBundle] loadNibNamed:@"TableHeadView" owner:self options:nil] objectAtIndex:0];
    [headView setIsSelected:([item.isSelected isEqualToString:@"1"]?YES:NO)];
    [headView.titleLbl setText:item.title];
    [headView setIndexSection:section];
    [headView setDelegate:self];
    return headView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark editing

- (BOOL)isEditingMode{
    return self.table.editing;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{

    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    CategoryItem *item = items[indexPath.section];

    if (editingStyle == UITableViewCellEditingStyleInsert) {
        item.isFavorite = @"1";
        [OnlineStoreController addToListName:@"Favorites" withDataStr:item.title];
    }else{
        item.isFavorite = @"0";
        [OnlineStoreController removeFromListName:@"Favorites" withDataStr:item.title];
    }
    [self sortItems];
    [self.table reloadData];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    CategoryItem *item = items[indexPath.section];
    if ([item.title isEqualToString:@"Top Stories"]) {
        return UITableViewCellEditingStyleNone;
    }
    if ([item.isFavorite isEqualToString:@"1"]) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleInsert;
}

- (void)sectionDidSelectWithSectionIndex:(NSNumber*)section{
    CategoryItem *item = items[section.integerValue];
    if ([item.isSelected isEqualToString:@"1"]) {
        [item setIsSelected:@"0"];
        [OnlineStoreController removeFromListName:@"Selected" withDataStr:item.title];
    }else{
        [item setIsSelected:@"1"];
        [OnlineStoreController addToListName:@"Selected" withDataStr:item.title];
    }
    
    [self.table reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:section.integerValue]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)showNewsDetailWithIdentifier:(NSString *)identifier{
    for (int i = 0; i < [items count]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
        FeedData *feedData = [self createDataForCellAtIndexPath:indexPath];
        for (int j = 0; j < [[feedData items] count]; j++) {
            MWFeedItem *item = feedData.items[j];
            if ([item.identifier isEqualToString:identifier]) {

                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:feedData, @"feedData",feedData.categoryItem, @"categoryItem" ,[NSNumber numberWithInt:j], @"selectedIndex", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"FeedItemDidSelected" object:dict];
                return;
            }
        }
    }
}


- (BOOL)hasNewsDetailWithIdentifier:(NSString *)identifier{
    for (int i = 0; i < [items count]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
        FeedData *feedData = [self createDataForCellAtIndexPath:indexPath];
        for (int j = 0; j < [[feedData items] count]; j++) {
            MWFeedItem *item = feedData.items[j];
            if ([item.identifier isEqualToString:identifier]) {
                return  YES;
            }
        }
    }
    return NO;
}

- (BOOL)newsHasWithIdentifier:(NSString *)identifier{
    for (int i = 0; i < [items count]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
        FeedData *feedData = [self createDataForCellAtIndexPath:indexPath];
        for (int j = 0; j < [[feedData items] count]; j++) {
            MWFeedItem *item = feedData.items[j];
            if ([item.link isEqualToString:identifier]) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)showNewsDetail:(NSNotification *)notification{
    NSDictionary *dictData = notification.object;
    if ([dictData objectForKey:@"selectedInPages"]) {
        return;
    }
    FeedData *feedData = [dictData objectForKey:@"feedData"];
    CategoryItem *itemsInfo = [dictData objectForKey:@"categoryItem"];
    int itemIndex = [[dictData objectForKey:@"selectedIndex"] integerValue];
    if (feedData.items) {
        if (!pageViewController) {
            pageViewController = [[PageViewController alloc] initWithData:feedData.items];
            [pageViewController setDelegate:self];
//            [pageViewController scrollDisable];
        }else{
            [pageViewController setItems:feedData.items];
        }
        pageViewController.categoryItem = itemsInfo;
        pageViewController.feedData = feedData;
        pageViewController.currentPageIndex = itemIndex;

        if (IS_IPAD) {
            [self.dragVC.view addSubview:pageViewController.view];
            [pageViewController.view setFrame:CGRectMake(0, 0, self.dragVC.view.frame.size.width, self.dragVC.view.frame.size.height)];
            if(self.dragVC.canMove && ![dictData objectForKey:@"noClose"])
            {
                [self.dragVC closeView];
                [self.view insertSubview:self.latestNewsView.view belowSubview:_dragVC.view];
            }
            [pageViewController updateUI];

        }else{
            [pageViewController updateUI];
            [self.navigationController pushViewController:pageViewController animated:YES];
            pageViewController = nil;
        }
        if (itemsInfo && itemsInfo.title) {
            [pageViewController.categoryTitleLbl setText:[itemsInfo.title uppercaseString]];
        }

    }
}

- (UIView *)createFooterView
{
    NSString *nibName ;
    if (IS_IPAD) {
        nibName = @"FooterView_iPad";
    }else{
        nibName = (UIInterfaceOrientationIsPortrait(SCREEN_ORIENTATION))?@"FooterView":
        ((IS_IPHONE_5)?@"FooterViewLarge_iPhone_5":@"FooterViewLarge");
    }
    footerView = [[[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil] lastObject];
    [footerView setDelegate:self];
    return footerView;
}

#pragma mark - ActionSheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:     // Email
            break;
            
        case 1:     // Twitter
            break;
            
        case 2:     // Facebook
            break;
            
        case 3:     // Copy web link
            break;
            
    }
}

#pragma mark - Autorotation

- (BOOL)shouldAutorotate{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateUI];
    self.dataModel.isLoaded = NO;
//    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    self.table.width = self.view.width;
    [self.table setTableFooterView:[self createFooterView]];
    if (self.latestNewsView) {
        self.latestNewsView.view.width = self.table.width;
    }
}

-(void)viewDidLoad {
	[super viewDidLoad];
    if (!pageViewController) {
        pageViewController = [[PageViewController alloc] initWithData:nil];
        [pageViewController setDelegate:self];

        if(IS_IPAD && UIInterfaceOrientationIsPortrait(SCREEN_ORIENTATION))
            [pageViewController scrollDisable];
    }
    [self.table setBackgroundColor:[UIColor clearColor]];
    [self.view setBackgroundColor:RGBCOLOR(110, 110, 110)];
    [self.table setSeparatorColor:[UIColor clearColor]];
    [self createObservers];
    [self addDragView];
    [self createRefreshView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNewsDetail:) name:@"FeedItemDidSelected" object:nil];
}

- (void)createLatestPanel{
    if (!self.latestNewsView) {
        self.latestNewsView = [LatestViewController new];
        [self.latestNewsView loadData];
        [self.latestNewsView setDelegateTable:self];
        if (IS_IPAD) {
            [self.view insertSubview:self.latestNewsView.view aboveSubview:self.table];
        }else{
            [self.view addSubview:self.latestNewsView.view];
        }
        self.latestNewsView.view.y -= self.latestNewsView.view.height;
    }
}

- (void)showLatestView{
    self.latestNewsView.view.width = self.table.width;
    CGRect latestFrame = self.latestNewsView.view.frame;
    CGRect tableFarme = self.table.frame;
    latestFrame.origin.y = 0;
    tableFarme.origin.y = self.latestNewsView.view.height;
    tableFarme.size.height = TABLE_HEIGHT;// self.latestNewsView.view.height;
    [UIView animateWithDuration:.3 animations:^{
        self.latestNewsView.view.y = 0;
        self.table.frame = tableFarme;
    }];
}

- (void)hideLatestView{
    CGRect tableFarme = self.table.frame;
    tableFarme.origin.y = -self.latestNewsView.view.height;
    tableFarme.size.height = TABLE_HEIGHT - self.latestNewsView.view.height;
    [UIView animateWithDuration:.3 animations:^{
        self.table.frame = tableFarme;
    }];
}

//refresh table content data
- (void)createRefreshView{
    if (!refreshControl) {
        refreshControl = [[UIRefreshControl alloc] init];
    }
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.table addSubview:refreshControl];
}

-(void)handleRefresh:(UIRefreshControl *)refresh {
    [self.dataModel.dataStore getNewsList];
}

- (void)updateNavBar
{
    if(IS_IPAD)
    {
        UIButton *sectionsButton = [Helpers createButtonWithNormalImg:[UIImage imageNamed:@"sectionsBtnNorm"] highlightImg:[UIImage imageNamed:@"sectionsBtnHighlight"] delegate:self selector:@selector(onSections:)];
        
        UIButton *editButton;
        
        if (self.table.isEditing)
        {
            editButton = [Helpers createButtonWithNormalImg:[UIImage imageNamed:@"DoneBtn"] highlightImg:[UIImage imageNamed:@"DoneBtnNewPress"] delegate:self selector:@selector(onDone:)];
        }
        else
        {
            editButton = [Helpers createButtonWithNormalImg:[UIImage imageNamed:@"editBtnNew"] highlightImg:[UIImage imageNamed:@"editBtnNewPress"] delegate:self selector:@selector(onEdit:)];
        }
        
        UIButton *radioButton = [Helpers createButtonWithNormalImg:[UIImage imageNamed:@"liveRadio"] highlightImg:[UIImage imageNamed:@"liveRadio"] delegate:self selector:@selector(onLiveRadioBtn:)];
        if ([[AppDelegate sharedDelegate] isRadioPlaying]) {
            [radioButton setSelected:YES];
        }else{
            [radioButton setSelected:NO];
        }
      //  [self aplyAnimationForRadiopButton:radioButton];
        
        // Right navigation items
        
        self.zoomTextButton = [Helpers createButtonWithNormalImg:[UIImage imageNamed:@"zoomTextBtnNorm"] highlightImg:[UIImage imageNamed:@"zoomTextBtnHighlight"] delegate:pageViewController selector:@selector(onZoomTextBtn:)];
        
        UIButton *shareButton = [Helpers createButtonWithNormalImg:[UIImage imageNamed:@"shareBtnNorm"] highlightImg:[UIImage imageNamed:@"shareBtnHighlight"] delegate:pageViewController selector:@selector(onShareBtn:)];
        
        UIView *rightView = [Helpers createViewWithButtons:@[self.zoomTextButton, shareButton]];
        UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
        [self.navigationItem setRightBarButtonItem:rightBtnItem];

        UIView *leftView ;
        if (UIInterfaceOrientationIsPortrait(SCREEN_ORIENTATION)){
            // Left navigation items
            if (self.dragVC.closed) {
                leftView = [Helpers createViewWithButtons:@[sectionsButton]];
            }else{
                leftView = [Helpers createViewWithButtons:@[sectionsButton,editButton]];
            }
        }else{
            // Left navigation items
            leftView = [Helpers createViewWithButtons:@[editButton]];
        }
        UIBarButtonItem *leftBtnItem = [[UIBarButtonItem alloc] initWithCustomView:leftView];
        [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    }
    else
    {
        // Left navigation items
        
        UIButton *radioButton;
        
        if(UIInterfaceOrientationIsPortrait(SCREEN_ORIENTATION))
        {
            radioButton = [Helpers createButtonWithNormalImg:[UIImage imageNamed:@"liveRadio"] highlightImg:[UIImage imageNamed:@"liveRadioRed0"] delegate:self selector:@selector(onLiveRadioBtn:)];
        }
        else
        {
            radioButton = [Helpers createButtonWithNormalImg:[UIImage imageNamed:@"liveRadioLandscape"] highlightImg:[UIImage imageNamed:@"liveRadio0Landscape"] delegate:self selector:@selector(onLiveRadioBtn:)];
        }
        
    //    UIBarButtonItem *radioBtnItem = [[UIBarButtonItem alloc] initWithCustomView:radioButton];
     //   [self.navigationItem setLeftBarButtonItem:radioBtnItem];
        if ([[AppDelegate sharedDelegate] isRadioPlaying]) {
            [radioButton setSelected:YES];
        }else{
            [radioButton setSelected:NO];
        }
        [self aplyAnimationForRadiopButton:radioButton];
        
        // Right navigation items
        
        UIButton *editButton;
        
        if (self.table.isEditing)
        {
            if(UIInterfaceOrientationIsPortrait(SCREEN_ORIENTATION))
            {
                editButton = [Helpers createButtonWithNormalImg:[UIImage imageNamed:@"DoneBtn"] highlightImg:[UIImage imageNamed:@"DoneBtnNewPress"] delegate:self selector:@selector(onDone:)];
            }
            else
            {
                editButton = [Helpers createButtonWithNormalImg:[UIImage imageNamed:@"DoneBtnLandscape"] highlightImg:[UIImage imageNamed:@"DoneBtnLandscapePress"] delegate:self selector:@selector(onDone:)];
            }
        }
        else
        {
            if(UIInterfaceOrientationIsPortrait(SCREEN_ORIENTATION))
            {
                editButton = [Helpers createButtonWithNormalImg:[UIImage imageNamed:@"editBtnNew"] highlightImg:[UIImage imageNamed:@"EditBtnNewPress"] delegate:self selector:@selector(onEdit:)];
            }
            else
            {
                editButton = [Helpers createButtonWithNormalImg:[UIImage imageNamed:@"EditBtnLandscape"] highlightImg:[UIImage imageNamed:@"EditBtnLandscapePress"] delegate:self selector:@selector(onEdit:)];
            }
        }

        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:editButton];
        [self.navigationItem setRightBarButtonItem:barButtonItem];
        
    }
}

#pragma mark - Notifications

- (void)dragViewOpened:(NSNotification *)note
{
    [pageViewController scrollDisable];
    self.dragVC.canMove = YES;
    [self updateNavBar];
}

- (void)dragViewClosed:(NSNotification *)note
{
    [pageViewController scrollEnabled];
    self.dragVC.canMove = NO;
    [self updateNavBar];
}

#pragma mark - Actions

- (void)aplyAnimationForRadiopButton:(UIButton *)btn{
        if(btn.selected)
        {
            if(UIInterfaceOrientationIsPortrait(SCREEN_ORIENTATION))
            {
                [btn setImage:[UIImage imageNamed:@"liveRadioRed0"] forState:UIControlStateNormal];
                btn.imageView.animationImages = @[[UIImage imageNamed:@"liveRadioRed0.png"], [UIImage imageNamed:@"liveRadioRed1.png"], [UIImage imageNamed:@"liveRadioRed2.png"]];
            }
            else
            {
                if(IS_IPAD)
                {
                    [btn setImage:[UIImage imageNamed:@"liveRadioRed0"] forState:UIControlStateNormal];
                    btn.imageView.animationImages = @[[UIImage imageNamed:@"liveRadioRed0.png"], [UIImage imageNamed:@"liveRadioRed1.png"], [UIImage imageNamed:@"liveRadioRed2.png"]];
                    
                }
                else
                {
                    [btn setImage:[UIImage imageNamed:@"liveRadio0Landscape"] forState:UIControlStateNormal];
                    btn.imageView.animationImages = @[[UIImage imageNamed:@"liveRadio0Landscape.png"], [UIImage imageNamed:@"liveRadio1Landscape.png"], [UIImage imageNamed:@"liveRadio2Landscape.png"]];
                    
                }
            }
            
            btn.imageView.animationDuration = 1.5;
            [btn.imageView startAnimating];
            [[AppDelegate sharedDelegate] playRadio];
        }
        else
        {
            if(UIInterfaceOrientationIsPortrait(SCREEN_ORIENTATION))
            {
                [btn setImage:[UIImage imageNamed:@"liveRadio"] forState:UIControlStateNormal];
            }
            else
            {
                [btn setImage:[UIImage imageNamed:@"liveRadioLandscape"] forState:UIControlStateNormal];
            }

            [btn.imageView stopAnimating];
            [[AppDelegate sharedDelegate] stopRadio];
        }
}

- (void)onLiveRadioBtn:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    [btn setSelected:!btn.selected];
    
    if(btn.selected)
    {
        [[AppDelegate sharedDelegate] playRadio];
    }
    else
    {
        [[AppDelegate sharedDelegate] stopRadio];
    }
    [self aplyAnimationForRadiopButton:btn];
}

- (void)onEdit:(id)sender
{
    [self.table setEditing:!self.table.editing];
    [self.table reloadData];
    [self updateNavBar];
}

- (void)onDone:(id)sender
{
    [self.table setEditing:NO];
    [self.table reloadData];
    [self updateNavBar];
}

- (void)onSections:(id)sender
{
    if(UIInterfaceOrientationIsPortrait(SCREEN_ORIENTATION))
    {
        if(self.dragVC.closed)
            [self.dragVC openView];
        else
            [self.dragVC closeView];
        self.dragVC.canMove = YES;
    }else{
//        self.dragVC.canMove = YES;
    }
}

#pragma mark UI drawing

- (void)addDragView
{
    if(!IS_IPAD)
        return;
    
    if(!self.dragVC)
    {
        self.dragVC = [[DragViewController alloc] init];
        [self.view addSubview:self.dragVC.view];
        
    }
}

- (void)updateUI
{
    [self updateNavBar];
    if(self.dragVC)
    {
        self.table.width = self.view.width - [DragViewController getWidth];
        self.dragVC.view.y = 0;
        self.dragVC.view.x = self.view.width - [DragViewController getWidth];
        if (!self.dragVC.canMove) {
            self.dragVC.view.width = self.view.width - self.dragVC.view.x;
        }else{
            self.dragVC.view.width = self.view.width;
        }
        self.dragVC.view.height = self.view.height;
        
        self.latestNewsView.view.width = self.table.width;
    }
}

#pragma mark sharing
- (void)showMailForm{
    if ([MFMailComposeViewController canSendMail]) {
        // Show the composer
    } else {
        // Handle the error
    }
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    NSString *theme = [NSString stringWithFormat:@"Send from Vagus News %@ app",(IS_IPAD)?@"iPad":@"iPhone"];
    [controller setSubject:theme];
    NSArray *toRecipients = [NSArray arrayWithObject:@"editor@vagus.tv"];
    [controller setToRecipients:toRecipients];
    [controller setMessageBody:theme isHTML:NO];
    if (controller) [self presentViewController:controller animated:YES
                                     completion:^{
                                         
                                     }];
}

- (void)showMailFormWithImage:(UIImage*)image{
    NSMutableString *emailBody = [[NSMutableString alloc] initWithString:@"<html><body>"];
    [emailBody appendString:[NSString stringWithFormat:@"<p>Send from Vagus News %@ app</p>",(IS_IPAD)?@"iPad":@"iPhone"]];
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
    NSString *base64String = [imageData base64EncodedString];
    [emailBody appendString:[NSString stringWithFormat:@"<p><b><img src='data:image/png;base64,%@'></b></p>",base64String]];
    [emailBody appendString:@"</body></html>"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideLoading];
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    NSString *theme = [NSString stringWithFormat:@"Send from Vagus News %@ app",(IS_IPAD)?@"iPad":@"iPhone"];
    [controller setSubject:theme];
        NSArray *toRecipients = [NSArray arrayWithObject:@"editor@vagus.tv"];
        [controller setToRecipients:toRecipients];
    [controller setMessageBody:emailBody isHTML:YES];
    
        if (controller) [self presentViewController:controller animated:YES
                                         completion:^{
                                             
                                         }];
    });

}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showPhotoPiker:(id)sender{
    if (!imagePickerController) {
            imagePickerController = [ [ UIImagePickerController alloc ] init ] ;
    }
    imagePickerController.delegate   = self ;
    imagePickerController.editing    = NO ;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
        popOverController = [[UIPopoverController alloc] initWithContentViewController:
                             imagePickerController];
        [popOverController presentPopoverFromRect:CGRectMake(70, self.table.height - 50, 0, 0) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
        
    }else {
        [self presentViewController:imagePickerController animated:YES completion:^{

        }];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
     NSLog(@"loadDataWithImgArray %@",info);
    UIImage *myImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self showLoading];
    if (IS_IPAD) {
        [popOverController dismissPopoverAnimated:YES];
        [self performSelectorInBackground:@selector(showMailFormWithImage:) withObject:myImage];
    }else{
        [self dismissViewControllerAnimated:NO completion:^{
            [self performSelectorInBackground:@selector(showMailFormWithImage:) withObject:myImage];
        }];
    }
}

#pragma mark rotation
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:orientation duration:duration];
    [self updateUI];
    if (IS_IPAD)
    {
        if (UIInterfaceOrientationIsPortrait(orientation))
        {
            self.dragVC.canMove = YES;
            [pageViewController scrollDisable];
        }
        else
        {
            //             self.dragVC.canMove = NO;
            
            [pageViewController.view setFrame:CGRectMake(pageViewController.view.frame.origin.x, pageViewController.view.frame.origin.y, self.dragVC.view.width, self.dragVC.view.frame.size.height)];
            [pageViewController clearUI];
            [pageViewController scrollEnabled];
        }
    }
    else
    {
        self.table.width = UIInterfaceOrientationIsPortrait(orientation) ? SCREEN_WIDTH : SCREEN_HEIGHT;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self updateUI];
    
    if (IS_IPAD)
    {
        if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)){
            [self.dragVC closeView];
            [pageViewController.view setFrame:CGRectMake(pageViewController.view.frame.origin.x, 0, self.dragVC.view.width, self.dragVC.view.frame.size.height)];
        }else{
            [pageViewController.view setFrame:CGRectMake(pageViewController.view.frame.origin.x, 0, 516, self.dragVC.view.frame.size.height)];
        }
        [pageViewController updateUI];
    }else{
        [self.table setTableFooterView:[self createFooterView]];
    }
    self.dragVC.canMove = (UIInterfaceOrientationIsPortrait(fromInterfaceOrientation))?NO:YES;
    self.latestNewsView.view.width = self.table.width;
    [self.view insertSubview:self.latestNewsView.view aboveSubview:self.table];
}
@end
