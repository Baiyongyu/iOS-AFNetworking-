//
//  NSObject+Additions.h
//  AFNetworking的网络层方案设计
//
//  Created by 宇玄丶 on 2017/3/17.
//  Copyright © 2017年 北京116工作室. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString* safeString(id obj);
NSNumber* safeNumber(id obj);

@interface NSObject (Additions)

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

@end
