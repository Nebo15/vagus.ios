//
//  HitTestView.m
//  BBC_News
//
//  Created by user on 7/19/13.
//
//
#import "CustomHitScrollView.h"

@implementation CustomHitScrollView

-(void)setContentStartInteractingPoint:(int) point {
    scrolInteractingPoint = point;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (point.y < scrolInteractingPoint) {
        for (UIView *view in self.hitSubviews) {
            if (CGRectContainsPoint(view.frame, point)) {
                return [view hitTest:point withEvent:event];
            }
        }
        return [upScrollView hitTest:point withEvent:event];
    }
    
    return [super hitTest:point withEvent:event];
}

@end
