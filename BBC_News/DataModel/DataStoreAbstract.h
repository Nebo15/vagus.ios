//
//  DataStoreAbstract.h
//  BBC_News
//
//  Created by Vitalii Todorovych on 26.05.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

@protocol DataStoreProtocol <NSObject>

-(void)dataDidFinishLoad:(id)data;
-(void)dataDidFailLoadWithError:(NSError*)error;

@end

@class BaseDataModel;
@interface DataStoreAbstract : NSObject{

}

@property (nonatomic, weak)  BaseDataModel *dataModel;
@property (nonatomic, weak)  id  viewControllerDelegate;

- (id)initWithDataModelDelegate:(id)delegateModel viewControllerDelegate:(id)delegateViewController;

//- (void)getNewsDetail;
- (void)getNewsWithURL:(NSString*)url;
- (void)getNewsList;
- (void)getLatestNewsList;

+ (NSArray*)getFavorites;
+ (NSArray*)getSelected;
+ (BOOL)addToListName:(NSString*)listName withDataStr:(NSString*)newsTitle;
+ (BOOL)removeFromListName:(NSString*)listName withDataStr:(NSString*)newsTitle;

@end
