//
//  QQQStoreModel.h
//  BBC_News
//
//  Created by Edwin Zuydendorp on 3/12/12.
//  Copyright 2012 QQQ. All rights reserved.
//

#import "DataStoreAbstract.h"

@protocol BaseDataModelProtocol <NSObject>

@optional
-(void)modelDidStartLoad:(id)model;
-(void)modelDidFinishLoad:(id)model;
-(void)modelDidFailLoadWithError:(NSError*)error;
-(void)modelDidCancelLoad:(id)model;

@end

@interface BaseDataModel : NSObject <DataStoreProtocol> {
}

@property (nonatomic,strong) DataStoreAbstract *dataStore;
@property (nonatomic,unsafe_unretained) id <BaseDataModelProtocol> delegate;
@property (nonatomic,strong) id data;
@property SEL callbackSelector;
@property (nonatomic) BOOL isLoading;
@property (nonatomic) BOOL isLoaded;
@property (nonatomic) BOOL isOutdated;

- (id)initWithDelegate:(id)_delegate;

//- (BOOL)isLoaded;
//- (BOOL)isLoading;
//- (BOOL)isOutdated;

- (void)loadData;
- (void)dataWillLoad;
- (void)dataDidLoad;
- (void)invalidate:(BOOL)erase;

@end
