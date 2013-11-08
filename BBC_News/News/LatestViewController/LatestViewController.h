//
//  LatestViewController.h
//  BBC_News
//
//  Created by Vitalii Todorovych on 20.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import "BaseDataModelViewController.h"
@class NewsListViewController;
@class TTTAttributedLabel;
@interface LatestViewController : BaseDataModelViewController{
    NSArray *items;
    NSString *currentIdentifier;
    int curIndex;
}

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *latestNewsLabel;
@property (weak) NewsListViewController *delegateTable;
@property (weak, nonatomic) IBOutlet UIImageView *arrowIcon;

- (void)loadData;
- (IBAction)latestNewsDidLoad:(id)sender;

@end
