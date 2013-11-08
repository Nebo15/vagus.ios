//
//  HitTestView.h
//  BBC_News
//
//  Created by user on 7/19/13.
//
//

#import <UIKit/UIKit.h>

@interface CustomHitScrollView : UIScrollView {
    int scrolInteractingPoint;
    UIView *upScrollView;
}

@property (nonatomic,strong) NSMutableArray *hitSubviews;

@end
