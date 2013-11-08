//
//  NSString+Interaction.m
//  iCollab
//
//  Created by Yalantis on 05.04.10.
//  Copyright 2010 Yalantis. All rights reserved.
//

#import "NSString+Interaction.h"

@implementation NSString (Interaction)

- (NSString *)flattenHTML {
	
	NSString *retValue = self;
    NSScanner *theScanner;
    NSString *text = nil;
	
    theScanner = [NSScanner scannerWithString:self];
	
    while ([theScanner isAtEnd] == NO) {
        [theScanner scanUpToString:@"<" intoString:NULL] ; 
        [theScanner scanUpToString:@">" intoString:&text] ;
        retValue = [retValue stringByReplacingOccurrencesOfString: [NSString stringWithFormat:@"%@>", text] withString:@" "];
    }
    return retValue;
}

- (BOOL) validateEmail {
    NSString *regexp = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexp]; 
	
    return [test evaluateWithObject:self];
}

- (BOOL) validateAlphanumeric {
    NSString *regexp = @"[\\w ]*"; 
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexp]; 
	
    return [test evaluateWithObject:self];
}

- (NSString*)replaceSubStringIn:(NSString*)str withString:(NSString*)newStr byRegularExpressionWithPattern:(NSString*)exptPtr{
    NSMutableString *mutableHtml = [str mutableCopy];
    while (YES) {
        NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:exptPtr
                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                  error:NULL];
        
        NSArray *array = [regexp matchesInString:mutableHtml options:0 range:NSMakeRange(0, mutableHtml.length)];
        if ([array count] == 0) {
            break;
        }
        NSRange matchRange;
        NSTextCheckingResult *res;
        for (NSTextCheckingResult *_res in array)
        {
            res = _res;
            matchRange = [res rangeAtIndex:1];
        }
        
        mutableHtml = [[regexp stringByReplacingMatchesInString:mutableHtml options:0 range:NSMakeRange(res.range.location, matchRange.location - res.range.location) withTemplate:newStr] mutableCopy];
    }
    return mutableHtml;
}

- (NSString*)replaceSubStringSeccondIn:(NSString*)str withString:(NSString*)newStr byRegularExpressionWithPattern:(NSString*)exptPtr{
    NSMutableString *mutableHtml = [str mutableCopy];
    
    while ([mutableHtml replaceOccurrencesOfString:exptPtr withString:newStr options:0 range:NSMakeRange(0, mutableHtml.length)]
           ) {}
    return mutableHtml;
    while (YES) {
        NSRegularExpression *dirtyREXP =
        [NSRegularExpression regularExpressionWithPattern:str options:NSRegularExpressionCaseInsensitive error:NULL];
        NSRange dirtyRange = [dirtyREXP rangeOfFirstMatchInString:str
                                                          options:0
                                                            range:NSMakeRange(0, str.length)];
        if (dirtyRange.location < str.length)
        {
            str = [str stringByReplacingCharactersInRange:dirtyRange withString:newStr];
        }else{
            break;
        }
    }
    return str;
}

@end
