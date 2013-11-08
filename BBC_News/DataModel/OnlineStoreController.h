//
//  OnlineStoreController.h
//  BBC_News
//
//  Created by Vitalii Todorovych on 26.05.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import "DataStoreAbstract.h"
#import "BaseDataModel.h"

#import "WBRequest.h"
#import "WBEngine.h"
#import "WBConnection.h"

@interface OnlineStoreController : DataStoreAbstract{
    WBEngine        *_wbEngine;
    
//    SEL             callbackSeloctor;
    void            (^callbackBlock)(NSDictionary *dic);
    void            (^callbackBlockWithFeedItems)(NSMutableArray *dic);
}

@property (nonatomic,retain)NSDictionary *resultDic;

- (void)loadDataWithUrl:(NSString*)url;

@end
