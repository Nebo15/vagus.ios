//
//  PageController
//  Depositreport
//
//  Created by davchik on 03.05.13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PageController.h"
#import "UIImage+UIImage_SafeResizable.h"

#define PAGINATOR_ACTIVE_IMAGE [[UIImage imageNamed:@"Paginator_active"] safeResizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 4, 4)]
#define PAGINATOR_PASSIVE_IMAGE [[UIImage imageNamed:@"Paginator_passive"] safeResizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 3, 3)]
#define HEIGHT 35
#define OFFSET_BETWEN_ITEMS 6
#define ITEMS_SHOWING_COUNT 3
#define BOTTOM_OFFSET 2
#define MAX_WIDTH_ITEM 20
#define HEIGHT_ITEM 10
#define FONT [UIFont boldSystemFontOfSize:7]

@implementation PageController

- (id)initWithPageCount:(int)countValue frame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, HEIGHT)];
    if (self) {
        count = countValue;
    }
    return self;
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    [self createUI];
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, HEIGHT)];
    [self createUI];
}

//- (void)createStatisticArrayWithDefaultValue:(NSArray*)results{
//    _statistics = [NSMutableArray new];
//        for (int i = 0; i < count; i++) {
//            [self.statistics addObject:[NSNumber numberWithInt:ResultNo]];
//        }
//}

- (void)setPageCount:(int)countValue{
    count = countValue;
    [self createUI];
}

- (void)createUI{
    [self setScrollEnabled:NO];
    [self setShowsHorizontalScrollIndicator:NO];
    [self setShowsVerticalScrollIndicator:NO];
    [self clearContent];
    float offsetX = 0.0;
    for (int index = 0; index < count && count > 1; index++) {
        UIImage *image = (index == self.currentIndex)?PAGINATOR_ACTIVE_IMAGE:PAGINATOR_PASSIVE_IMAGE;
        NSString *text = [NSString stringWithFormat:((index == self.currentIndex)?@"%d":@"%d"),index+1];
        offsetX = OFFSET_BETWEN_ITEMS + offsetX;
        CGSize textSize = [text sizeWithFont:FONT constrainedToSize:CGSizeMake(MAX_WIDTH_ITEM, HEIGHT_ITEM) lineBreakMode:NSLineBreakByCharWrapping];
        textSize.width += 4;
        CGRect frameLbl = CGRectMake(offsetX, HEIGHT - HEIGHT_ITEM - BOTTOM_OFFSET, textSize.width, HEIGHT_ITEM);
        
        if ((index >= ITEMS_SHOWING_COUNT) && (index <= (count - 1 - ITEMS_SHOWING_COUNT)))
//            || ((index == ITEMS_SHOWING_COUNT+1) &&  (index == (count - ITEMS_SHOWING_COUNT))))
        {
            
            
            if (self.currentIndex >= ITEMS_SHOWING_COUNT && (self.currentIndex <= (count - 1 - ITEMS_SHOWING_COUNT))) {                
                //draw current element in top
                index = self.currentIndex;
                NSString *text = [NSString stringWithFormat:@"%d",self.currentIndex + 1];
                CGSize textSize = [text sizeWithFont:FONT constrainedToSize:CGSizeMake(MAX_WIDTH_ITEM, HEIGHT_ITEM) lineBreakMode:NSLineBreakByCharWrapping];
                textSize.width += 4;
                frameLbl = CGRectMake(frameLbl.origin.x/* + (textSize1.width - textSize.width)/2*/, frameLbl.origin.y, textSize.width, HEIGHT_ITEM);
                offsetX = [self addItemWithText:text frame:frameLbl backgroundImage:PAGINATOR_ACTIVE_IMAGE textColor:[UIColor whiteColor]];
//                offsetX -= 1;
                index = (count - 1 - ITEMS_SHOWING_COUNT);
                continue;
            }else if (count-1 > ITEMS_SHOWING_COUNT*2){//show middle object if there is not more 1 object
                
                //draw "..." element
                CGSize textSize = [@" ... " sizeWithFont:FONT constrainedToSize:CGSizeMake(MAX_WIDTH_ITEM, HEIGHT_ITEM) lineBreakMode:NSLineBreakByCharWrapping];
                frameLbl.size = CGSizeMake(textSize.width, HEIGHT_ITEM);
                offsetX = [self addItemWithText:@" ... " frame:frameLbl backgroundImage:PAGINATOR_PASSIVE_IMAGE textColor:nil];
                index = (count - 1 - ITEMS_SHOWING_COUNT);
                continue;
            }
            
        }
        offsetX = [self addItemWithText:text frame:frameLbl backgroundImage:image textColor:(index == self.currentIndex)?[UIColor whiteColor]:nil];
    }
    [self setContentSize:CGSizeMake(self.frame.size.width, HEIGHT)];
    float s = (self.frame.size.width - offsetX + OFFSET_BETWEN_ITEMS);
    [self setContentOffset:CGPointMake(-s/2, self.contentOffset.y)];
}

- (PageState)valueByIndex:(int)index{
    return PageUnSelected;
}

- (float)addItemWithText:(NSString*)text frame:(CGRect)frame backgroundImage:(UIImage*)image textColor:(UIColor*)textColor{
    UILabel *numberLbl = [[UILabel alloc] initWithFrame:frame];
    [numberLbl setFont:FONT];
    [numberLbl setTextAlignment:NSTextAlignmentCenter];
    [numberLbl setText:text];
    if (textColor) {
        [numberLbl setTextColor:textColor];
    }
    [numberLbl setBackgroundColor:[UIColor clearColor]];
    UIImageView *backImage = [[UIImageView alloc] initWithImage:image];
    float widht = (frame.size.width > image.size.width)?frame.size.width:image.size.width;
    [backImage setFrame:CGRectMake(0, 0, widht, image.size.height)];
    [backImage setCenter:numberLbl.center];
    [self addSubview:backImage];
    [self addSubview:numberLbl];
    return frame.origin.x + widht;
}

- (void)clearContent{
    for (UIView *view in self.subviews) {
        if (view != picker) {
            [view removeFromSuperview];
        }
    }
    [self setContentSize:CGSizeZero];
}

- (void)setSelectItemByIndex:(int)index{
    if (index >= count || index < 0) {
        return;
    }
    _currentIndex = index;
    [self createUI];
}

@end
