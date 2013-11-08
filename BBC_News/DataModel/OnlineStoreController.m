//
//  OnlineStoreController.m
//  BBC_News
//
//  Created by Vitalii Todorovych on 26.05.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import "OnlineStoreController.h"
#import "JSON.h"
#import "MWFeedParser.h"

@interface OnlineStoreController()<MWFeedParserDelegate>
@property (strong, nonatomic) MWFeedParser* pv_feedParser;
@property (strong, nonatomic) NSMutableArray* pv_items;
@end

@implementation OnlineStoreController

- (id)initWithDataModelDelegate:(id)delegateModel viewControllerDelegate:(id)delegateViewController
{
    self = [super initWithDataModelDelegate:delegateModel viewControllerDelegate:delegateViewController];
    if (self) {
        self.pv_items = [NSMutableArray array];
    }
    return self;
}

#pragma mark self loding functions

- (void)getLatestNewsList{
    [self loadDataWithUrl:[NSString stringWithFormat:@"http://polling.bbc.co.uk/moira/ticker/int"]];
    __weak OnlineStoreController *weakSelf = self;
    callbackBlock = ^(NSDictionary *dic){
        SEL selector = @selector(dataDidFinishLoad:);
        if ([weakSelf.dataModel respondsToSelector:selector]) {
            [weakSelf.dataModel performSelector:selector withObject:dic];
        }
    };
}

- (void)getNewsList{
    self.pv_feedParser = [[MWFeedParser alloc] initWithFeedURL:[[NSURL alloc] initWithString:@"http://vagus.tv/feed/atom/"]];
    self.pv_feedParser.delegate = self;
    self.pv_feedParser.feedParseType = ParseTypeFull;
    // Connection type
    self.pv_feedParser.connectionType = ConnectionTypeSynchronously;
    // Begin parsing
    [self.pv_feedParser parse];
//    [self loadDataWithUrl:[NSString stringWithFormat:@"http://vagus.tv/feed/atom/"]];
//    __weak OnlineStoreController *weakSelf = self;
//    callbackBlock = ^(NSDictionary *dic){
//        SEL selector = @selector(dataDidFinishLoad:);
//        if ([weakSelf.dataModel respondsToSelector:selector]) {
//            [weakSelf.dataModel performSelector:selector withObject:dic];
//        }
//    };
}


+ (NSArray*)getFavorites{
    NSArray *favoritesList = [[NSUserDefaults standardUserDefaults] arrayForKey:@"Favorites"];
    return favoritesList;
}

+ (NSArray*)getSelected{
    NSArray *favoritesList = [[NSUserDefaults standardUserDefaults] arrayForKey:@"Selected"];
    return favoritesList;
}

+ (BOOL)addToListName:(NSString*)listName withDataStr:(NSString*)newsTitle{
    if (!newsTitle) {
        return NO;
    }
    @try {
        NSArray *favoritesList = [[NSUserDefaults standardUserDefaults] arrayForKey:listName];
        BOOL hasObjFlag = NO;
        for (NSString *idObj in favoritesList) {
            if ([idObj isEqualToString:newsTitle]) {
                hasObjFlag = YES;
                return YES;
            }
        }
        if (!hasObjFlag) {
            NSMutableArray *data = [[NSMutableArray alloc] initWithArray:favoritesList];
            [data addObject:newsTitle];
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:listName];
            [[NSUserDefaults standardUserDefaults] synchronize];
//            [LocalDBController iCloudShareEntitie:@"Favorites"];
            return YES;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"ERROR: Data was not save.");
        return NO;
    }
    return YES;
}

+ (BOOL)removeFromListName:(NSString*)listName withDataStr:(NSString*)newsTitle{
    if (!newsTitle) {
        return NO;
    }
    @try {
        NSArray *favoritesList = [[NSUserDefaults standardUserDefaults] arrayForKey:listName];
        NSMutableArray *data = [[NSMutableArray alloc] initWithArray:favoritesList];
        for (NSString *idObj in data) {
            if ([idObj isEqualToString:newsTitle]) {
                [data removeObject:idObj];
                [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:data] forKey:listName];
                [[NSUserDefaults standardUserDefaults] synchronize];
//                [LocalDBController iCloudShareEntitie:@"Favorites"];
                break;
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"ERROR: Data was not remove.");
        return NO;
    }
    return YES;
}

#pragma mark WEB Engine
- (WBEngine*)wbEngine{
    if (!_wbEngine) {
        _wbEngine = [[WBEngine alloc] init];
    }
    return _wbEngine;
}

- (void)loadDataWithUrl:(NSString *)url{
    if (![AppDelegate isNetwork]) {
        if ([self.viewControllerDelegate respondsToSelector:@selector(showNetworkView)]) {
            [self.viewControllerDelegate performSelector:@selector(showNetworkView)];
        }
        return;
    }
    
    if ([self.viewControllerDelegate respondsToSelector:@selector(modelDidStartLoad:)]) {
        [self.viewControllerDelegate performSelector:@selector(modelDidStartLoad:) withObject:self];
    }
    WBRequest * _request = [WBRequest getRequestWithURL:url delegate:self];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    self.dataModel.isLoading = YES;
    self.dataModel.isLoaded = NO;
    [[self wbEngine] performRequest:_request withHashingKey:url];
}

#pragma mark - WBCEngineProtocol functions
- (void) connectionDidFinishLoading: (WBConnection*)connection {
	NSData *value = [connection data];
    NSString *response = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
    NSDictionary *_result = [[NSDictionary alloc] initWithDictionary:[response JSONValue]];
	if (_result) {
        self.resultDic = _result;
        self.dataModel.isLoaded = YES;
        if ((self.dataModel.isOutdated && [self wbEngine].hashingKey)||([self wbEngine].hashingKey)) {
            self.dataModel.isOutdated = NO;
            if ([self.viewControllerDelegate respondsToSelector:@selector(dataDidUpdated)]) {
                [self.viewControllerDelegate performSelector:@selector(dataDidUpdated) withObject:self];
            }
        }
        callbackBlock(_result);
	}else{
        if (![self wbEngine].isRepeatedRequest) {
            [self wbEngine].isRepeatedRequest = YES;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            WBRequest * _request = [WBRequest getRequestWithURL:[self wbEngine].hashingKey delegate:self];
            [[self wbEngine] performRequest:_request withHashingKey:[self wbEngine].hashingKey];
            return;
        }else{
            callbackBlock(nil);
            if ([self.viewControllerDelegate respondsToSelector:@selector(model:didFailLoadWithError:)]) {
                [self.viewControllerDelegate performSelector:@selector(model:didFailLoadWithError:) withObject:self withObject:@"Repeated Request error."];
            }
        }
    }
    self.dataModel.isLoading = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void) connection: (WBConnection*)connection didFailWithError: (NSError*)error{
    if (![self wbEngine].isRepeatedRequest) {
        [self wbEngine].isRepeatedRequest = YES;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        WBRequest * _request = [WBRequest getRequestWithURL:[self wbEngine].hashingKey delegate:self];
        [[self wbEngine] performRequest:_request withHashingKey:[self wbEngine].hashingKey];
        return;
    }
    self.dataModel.isLoading = NO;
    callbackBlock(nil);
    if ([self.viewControllerDelegate respondsToSelector:@selector(model:didFailLoadWithError:)]) {
        [self.viewControllerDelegate performSelector:@selector(model:didFailLoadWithError:) withObject:self withObject:error];
    }
}

#pragma mark - MWFeedParserDelegate

- (void)feedParserDidStart:(MWFeedParser *)parser
{
    
}// Called when data has downloaded and parsing has begun

- (void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info
{

}// Provides info about the feed

- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item
{
    if (!self.pv_items) {
        self.pv_items = [NSMutableArray array];
    }
    [self.pv_items addObject:item];
}// Provides info about a feed item

- (void)feedParserDidFinish:(MWFeedParser *)parser
{
    SEL selector = @selector(dataDidFinishLoad:);
    if ([self.dataModel respondsToSelector:selector]) {
        [self.dataModel performSelector:selector withObject:@{@"feeds": @[self.pv_items[0]]}];
    }
}
// Parsing complete or stopped at any time by `stopParsing`

- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error
{

}// Parsing failed

- (void)dealloc
{
    _wbEngine = nil;
}
@end
