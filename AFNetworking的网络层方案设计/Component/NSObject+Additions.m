//
//  NSObject+Additions.m
//  AFNetworking的网络层方案设计
//
//  Created by 宇玄丶 on 2017/3/17.
//  Copyright © 2017年 北京116工作室. All rights reserved.
//

#import "NSObject+Additions.h"

@implementation NSObject (Additions)

NSString* safeString(id obj) {
    return [obj isKindOfClass:[NSObject class]]?[NSString stringWithFormat:@"%@",obj]:@"";
}

NSNumber* safeNumber(id obj) {
    NSNumber *result=[NSNumber numberWithInt:0];
    if([obj isKindOfClass:[NSNumber class]])
    {
        result = obj;
        
    } else if ([obj isKindOfClass:[NSString class]]) {
        result = @(((NSString *)obj).doubleValue);
    }
    return result;
}

- (void)performBlock:(void (^)(void))block
          afterDelay:(NSTimeInterval)delay
{
    [self performSelector:@selector(fireBlockAfterDelay:)
               withObject:block
               afterDelay:delay];
}

- (void)fireBlockAfterDelay:(void (^)(void))block {
    block();
}

@end
