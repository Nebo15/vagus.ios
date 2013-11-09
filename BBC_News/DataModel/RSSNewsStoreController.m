//
//  RSSNewsStoreController.m
//  BBC_News
//
//  Created by Vitalii Todorovych on 15.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import "RSSNewsStoreController.h"
#import "NSString+HTML.h"
#import "MWFeedParser.h"

@implementation RSSNewsStoreController

- (void)getNewsWithURL:(NSString*)urlStr{
    if (feedParser) {
        [feedParser stopParsing];
    }
	[parsedItems removeAllObjects];

    formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterShortStyle];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	parsedItems = [[NSMutableArray alloc] init];
	self.itemsToDisplay = [NSArray array];
	
	// Parse
    NSString* url = [NSString stringWithString:urlStr];
	NSURL *feedURL = [[NSURL alloc] initWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    NSString *str = [NSString stringWithContentsOfURL:feedURL encoding:NSUTF8StringEncoding error:nil];
//    NSLog(@"%@",str);
	feedParser = [[MWFeedParser alloc] initWithFeedURL:feedURL];
	feedParser.delegate = self;
	feedParser.feedParseType = ParseTypeFull; // Parse feed info and all items
	feedParser.connectionType = ConnectionTypeAsynchronously;
	[feedParser parse];
}

#pragma mark parsing functions
#pragma mark -
#pragma mark Parsing

- (void)updateViewControllerWithParsedItems {
	self.itemsToDisplay = [parsedItems sortedArrayUsingDescriptors:
						   [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"date"
																				 ascending:NO]]];
    
    if (self.itemsToDisplay) {
        self.dataModel.isLoaded = YES;
        if ((self.dataModel.isOutdated)) {
            self.dataModel.isOutdated = NO;
            if ([self.viewControllerDelegate respondsToSelector:@selector(dataDidUpdated)]) {
                [self.viewControllerDelegate performSelector:@selector(dataDidUpdated) withObject:self];
            }
        }
        SEL selector = @selector(dataDidFinishLoad:);
        if ([self.dataModel respondsToSelector:selector]) {
            [self.dataModel performSelector:selector withObject:self.itemsToDisplay];
        }
        //        }
	}else{
        callbackBlock(nil);
        if ([self.viewControllerDelegate respondsToSelector:@selector(model:didFailLoadWithError:)]) {
            [self.viewControllerDelegate performSelector:@selector(model:didFailLoadWithError:) withObject:self withObject:@"Repeated Request error."];
        }
    }
    self.dataModel.isLoading = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark -
#pragma mark MWFeedParserDelegate

- (void)feedParserDidStart:(MWFeedParser *)parser {
//	NSLog(@"Started Parsing: %@", parser.url);
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info {
//	NSLog(@"Parsed Feed Info: “%@”", info.title);
//	self.title = info.title;
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item {
//	NSLog(@"Parsed Feed Item: “%@”", item.title);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSRegularExpression *regexp =
        [NSRegularExpression regularExpressionWithPattern:@"<a href=\"http://[^/]*/(.*)"
                                                  options:NSRegularExpressionCaseInsensitive
                                                    error:NULL];
        NSArray *array = [regexp matchesInString:item.summary options:0 range:NSMakeRange(0, item.summary.length)];
        NSRange matchRange;
        for (NSTextCheckingResult *res in array)
        {
            matchRange = [res rangeAtIndex:1];
        }
    
    
//        NSRegularExpression *dirtyREXP =
//        [NSRegularExpression regularExpressionWithPattern:@"(%7bdevice%7d)" options:NSRegularExpressionCaseInsensitive error:NULL];
//        NSRange dirtyRange = [dirtyREXP rangeOfFirstMatchInString:dirtyURL
//                                                          options:0
//                                                            range:NSMakeRange(0, dirtyURL.length)];
//        NSString *imageURL;
//        if (dirtyRange.location < dirtyURL.length)
//        {
//            imageURL = [dirtyURL stringByReplacingCharactersInRange:dirtyRange withString:@"iphone-retina"];
//            imageURL = [NSString stringWithFormat:@"http://%@", imageURL];
//        }
        if([item.summary rangeOfString:@".jpg"].location != NSNotFound)
        {
            NSString *dirtyURL = [item.summary substringWithRange:matchRange];

            dirtyURL = [dirtyURL substringToIndex:[dirtyURL rangeOfString:@".jpg"].location + 4];
            NSString *imageURL = [NSString stringWithFormat:@"http://vagus.tv/%@",dirtyURL];
            item.thumbnail = imageURL;
        }
    });

    
	if (item) [parsedItems addObject:item];
}

- (void)feedParserDidFinish:(MWFeedParser *)parser {
//	NSLog(@"Finished Parsing%@", (parser.stopped ? @" (Stopped)" : @""));
    [self updateViewControllerWithParsedItems];
}

- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error {
	NSLog(@"Finished Parsing With Error: %@", error);
    if (parsedItems.count == 0) {
//        self.title = @"Failed"; // Show failed message in title
    } else {
        // Failed but some items parsed, so show and inform of error
#if TARGET_IPHONE_SIMULATOR
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Parsing Incomplete"
                                                        message:@"There was an error during the parsing of this feed. Not all of the feed items could parsed."
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];
#endif
    }
    [self updateViewControllerWithParsedItems];
}

@end
