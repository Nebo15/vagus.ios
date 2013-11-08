//
//  CategoryItem.h
//  BBC_News
//
//  Created by Vitalii Todorovych on 18.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CategoryItem : NSObject

@property (strong) NSString *defaultStr;
@property (strong) NSString *movable;
@property (strong) NSString *title;
@property (strong) NSString *feed_url;
@property (strong) NSString *isFavorite;
@property (strong) NSString *isSelected;

- (id)initWithTitle:(NSString*)title feed_url:(NSString*)url;
- (id)initWithTitle:(NSString*)title feed_url:(NSString*)url defaultStr:(NSString*)defaultStr movable:(NSString*)movable;

@end
