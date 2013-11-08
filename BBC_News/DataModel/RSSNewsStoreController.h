//
//  RSSNewsStoreController.h
//  BBC_News
//
//  Created by Vitalii Todorovych on 15.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import "DataStoreAbstract.h"
#import "BaseDataModel.h"
#import "MWFeedParser.h"

@interface RSSNewsStoreController : DataStoreAbstract <MWFeedParserDelegate>{
    
    // Parsing
	MWFeedParser *feedParser;
	NSMutableArray *parsedItems;
    
	NSDateFormatter *formatter;
    void            (^callbackBlock)(NSArray *array);
}

@property (nonatomic, retain) NSArray *itemsToDisplay;

- (void)getNewsWithURL:(NSString*)url;

@end
