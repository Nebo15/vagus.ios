//
//  PageController
//  Depositreport
//
//  Created by davchik on 03.05.13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	PageUnSelected = 0,
	PageSelected
} PageState;

@interface PageController : UIScrollView{
    int count;
    UIView *picker;
}

@property (readonly) int currentIndex;

- (id)initWithPageCount:(int)countValue frame:(CGRect)frame;
- (void)setPageCount:(int)countValue;
- (void)setSelectItemByIndex:(int)index;

- (PageState)valueByIndex:(int)index;
@end
