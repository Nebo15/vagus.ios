//
//  WBEngine.h
//  WebsiteBuilder
//
//  Created by Yuri Kotov on 19.10.09.
//  Copyright 2009 Yalantis. All rights reserved.
//

@class WBRequest;
@class WBConnection;
#import "LoadingViewController.h"

@interface WBEngine : NSObject
{
    LoadingViewController *loadingView;
    NSString *errorMessage;
    
    NSString    *description;
    bool        hashingFlag;
    bool        isRepeatedRequest;
    NSString    *hashingKey;
}

@property (nonatomic,copy) NSString *errorMessage;
@property (nonatomic,strong) NSString *description;
@property (nonatomic) bool hashingFlag;
@property (nonatomic) bool isRepeatedRequest;
@property (nonatomic,strong) NSString *hashingKey;

- (BOOL) performRequest: (WBRequest*)request;
- (BOOL) performRequest: (WBRequest*)request withHashingKey:(NSString *)hashingKey;
-(void) showLoadingViewIn:(UIView *)superView loadingText:(NSString *)text;

- (void) closeLoadingView;
@end