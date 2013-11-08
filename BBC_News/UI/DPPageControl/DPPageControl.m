//
//  DPPageControl.m
//  
//
//  Created by Vitalii Todorovych on 27.12.12.
//  Copyright (c) 2012  Dev. All rights reserved.
//

#import "DPPageControl.h"

@implementation DPPageControl

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        activeImage = [UIImage imageNamed:@"selected_page_img"];
        inactiveImage = [UIImage imageNamed:@"unselected_page_img"];
    }
    return self;
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
}

-(void)updateDots
{
    if ([self.subviews count] != 0) {
        self.offset = (int)self.frame.size.width / [self.subviews count] / 2;
    }
    if (!self.offset || self.offset > 8) {
        self.offset = 8;
    }

    activeImage = [UIImage imageNamed:@"selected_page_img"];
    inactiveImage = [UIImage imageNamed:@"unselected_page_img"];
    for (int i = 0; i < [self.subviews count]; i++)
    {
        UIImageView* dot = [self.subviews objectAtIndex:i];
        if (IS_IPAD) {
            dot.frame = CGRectMake(dot.frame.origin.x, dot.frame.origin.y, 8, 8);
        }else{
            dot.frame = CGRectMake(self.offset*2 * i, dot.frame.origin.y, self.offset, self.offset);
        }
        if (i == self.currentPage)
            [dot addSubview:[[UIImageView alloc]initWithImage:activeImage]];
        else
            [dot addSubview:[[UIImageView alloc]initWithImage:inactiveImage]];
        [dot setNeedsDisplay];
    }
}

-(void)setCurrentPage:(NSInteger)page
{
    [super setCurrentPage:page];
    [self updateDots];
}
    
    


@end
