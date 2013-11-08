//
//  TableHeadView.m
//  BBC_News
//
//  Created by Vitalii Todorovych on 18.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import "TableHeadView.h"

@implementation TableHeadView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)didMoveToSuperview{
    if (self.isSelected) {
        [self rotateWithFlag:self.isSelected animation:NO];
    }
}

- (IBAction)didSelect:(id)sender{
    self.isSelected = !self.isSelected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(sectionDidSelectWithSectionIndex:)]) {
        [self.delegate performSelector:@selector(sectionDidSelectWithSectionIndex:) withObject:[NSNumber numberWithInt:self.indexSection]];
    }
    [self rotateWithFlag:self.isSelected animation:YES];
}

- (void)rotateWithFlag:(BOOL)flag animation:(BOOL)animation
{
    NSInteger angle = flag ? -90 : 0;
    CGAffineTransform rotateTrans = CGAffineTransformMakeRotation(angle * M_PI / 180);
    if (!animation) {
        self.arrowImView.transform = rotateTrans;
        return;
    }
    [UIView animateWithDuration:.5 animations:^{
        self.arrowImView.transform = rotateTrans;
    }];
    
}

- (void)dealloc
{
    
}

@end
