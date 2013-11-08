//
//  CategoryItem.m
//  BBC_News
//
//  Created by Vitalii Todorovych on 18.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import "CategoryItem.h"

@implementation CategoryItem

- (id)initWithTitle:(NSString*)title feed_url:(NSString*)url 
{
    self = [super init];
    if (self) {
        self.title = title;
        self.feed_url = url;
    }
    return self;
}


- (id)initWithTitle:(NSString*)title feed_url:(NSString*)url defaultStr:(NSString*)defaultStr movable:(NSString*)movable
{
    self = [super init];
    if (self) {
        self.title = title;
        self.feed_url = url;
        self.defaultStr = defaultStr;
        self.movable = movable;
    }
    return self;
}

@end
