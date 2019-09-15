//
//  KPSchemeManager.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPSchemeManager.h"
#import "KPScheme.h"

static NSMutableArray *_Nullable schemes = nil;

@implementation KPSchemeManager

static KPSchemeManager* _instance = nil;

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance ;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [KPSchemeManager shareInstance] ;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self getSchemes];
    }
    return self;
}

- (void)getSchemes{
    schemes = [[NSMutableArray alloc] init];
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"URLSchemes" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    for (NSString *key in dict) {
        KPScheme *scheme = [[KPScheme alloc] init];
        scheme.name = key;
        scheme.scheme = (NSString *)[dict valueForKey:key];
        NSLog(@"%@", scheme.name);
        [schemes addObject:scheme];
    }
}

- (NSArray *)getSchemeArr{
    return [schemes sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        KPScheme *s1 = (KPScheme *)obj1;
        KPScheme *s2 = (KPScheme *)obj2;
        NSString *number1 = [s1.name stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        NSString *number2 = [s2.name stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        
        NSComparisonResult result = [number1 compare:number2];
        
        return result == NSOrderedDescending; // 升序
    }];
}

@end
