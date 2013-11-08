//
//  QQQStoreModel.m
//  BBC_News
//
//  Created by Edwin Zuydendorp on 3/12/12.
//  Copyright 2012 QQQ. All rights reserved.
//

#import "BaseDataModel.h"
#import "OnlineStoreController.h"

@implementation BaseDataModel

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.delegate = nil;
}

- (id)initWithDelegate:(id)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createStreController) name:@"AppVersionUpdated" object:nil];
        [self createStreController];
        self.isLoaded = NO;
        self.isLoading = NO;
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createStreController) name:@"AppVersionUpdated" object:nil];
        [self createStreController];
        self.isLoaded = NO;
        self.isLoading = NO;
    }
    return self;
}

- (void)createStreController{
    self.dataStore = [[OnlineStoreController alloc] initWithDataModelDelegate:self viewControllerDelegate:self.delegate];
}

- (void)loadData{
}

- (void)dataWillLoad{
}

- (void)dataDidLoad{

}

- (void)invalidate:(BOOL)erase{
}

#pragma mark DataStoreProtocol

-(void)dataDidFinishLoad:(id)data{
    SEL selector = (self.callbackSelector)?self.callbackSelector:@selector(modelDidFinishLoad:);
    if ([self.delegate respondsToSelector:selector]) {
        [self.delegate performSelector:selector withObject:data];
    }
}

-(void)dataDidFailLoadWithError:(NSError*)error{
    SEL selector = @selector(modelDidFailLoadWithError:);
    if ([self.delegate respondsToSelector:selector]) {
        [self.delegate performSelector:selector withObject:error];
    }
}

@end
