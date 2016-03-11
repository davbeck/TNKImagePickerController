//
//  NSDate+TNKFormattedDay.m
//  Pods
//
//  Created by David Beck on 2/25/15.
//
//

#import "NSDate+TNKFormattedDay.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSDate (TNKFormattedDay)

- (NSString *)tnk_localizedDay {
    static NSDateFormatter *relativeFormatter = nil;
    static NSDateFormatter *comparisonFormatter = nil;
    static NSDateFormatter *weekdayFormatter = nil;
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        relativeFormatter = [NSDateFormatter new];
        relativeFormatter.dateStyle = NSDateFormatterMediumStyle;
        relativeFormatter.timeStyle = NSDateFormatterNoStyle;
        relativeFormatter.doesRelativeDateFormatting = YES;
        
        comparisonFormatter = [NSDateFormatter new];
        comparisonFormatter.dateStyle = NSDateFormatterMediumStyle;
        comparisonFormatter.timeStyle = NSDateFormatterNoStyle;
        
        weekdayFormatter = [NSDateFormatter new];
        weekdayFormatter.dateFormat = @"EEEE";
        
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"MMMM d" options:0 locale:nil];
    });
    
    NSString *dateString = nil;
    NSString *relativeString = [relativeFormatter stringFromDate:self];
    NSString *absoluteString = [comparisonFormatter stringFromDate:self];
    
    if (![relativeString isEqual:absoluteString]) {
        dateString = relativeString;
    } else if (-self.timeIntervalSinceNow < 60.0 * 60.0 * 24.0 * 7.0) {
        dateString = [weekdayFormatter stringFromDate:self];
    } else {
        dateString = [dateFormatter stringFromDate:self];
    }
    
    return dateString;
}

@end

NS_ASSUME_NONNULL_END
