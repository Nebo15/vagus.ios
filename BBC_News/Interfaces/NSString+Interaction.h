//
//  NSString+Interaction.h
//  iCollab
//
//  Created by Yalantis on 05.04.10.
//  Copyright 2010 Yalantis. All rights reserved.
//


@interface NSString (Interaction)

- (NSString *)flattenHTML;
- (BOOL) validateEmail;
- (BOOL) validateAlphanumeric;

- (NSString*)replaceSubStringIn:(NSString*)str withString:(NSString*)newStr byRegularExpressionWithPattern:(NSString*)exptPtr;
- (NSString*)replaceSubStringSeccondIn:(NSString*)str withString:(NSString*)newStr byRegularExpressionWithPattern:(NSString*)exptPtr;

@end
