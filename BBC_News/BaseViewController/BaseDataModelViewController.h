//
//  BaseDataModelNavigationView.h
//  BBC_News
//
//  Created by Edwin Zuydendorp on 3/12/12.
//  Copyright (c) 2012 QQQ. All rights reserved.
//
#import "BaseUploadDataViewController.h"
#import "BaseDataModel.h"

@interface BaseDataModelViewController : BaseUploadDataViewController
<BaseDataModelProtocol>
{
}

@property (nonatomic,retain) BaseDataModel *dataModel;

- (void)showModelDataIfPossible;
- (void)showModelData:(id)model;

- (void)showLoading;
- (void)hideLoading;
- (void)showReloadScreen;
- (void)createTitleImageWithImageName:(NSString*)name;

- (void)createModel;
- (void)dataBecomeObsolete;
- (void)dataDidUpdated;

@end
