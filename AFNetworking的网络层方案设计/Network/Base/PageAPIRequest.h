//
//  PageAPIRequest.h
//  AFNetworking的网络层方案设计
//
//  Created by 宇玄丶 on 2017/3/17.
//  Copyright © 2017年 北京116工作室. All rights reserved.
//

#import "BaseAPIRequest.h"

@protocol PageDelegate <NSObject>
@required
- (NSArray *)buildPageArray;
@end

@interface PageAPIRequest : BaseAPIRequest <APIManager>

/**
 *  当前页数
 */
@property (nonatomic, assign) NSUInteger                currentPage;
/**
 *  最终结果
 */
@property (nonatomic, strong) NSMutableArray*           listArray;
/**
 *  是否还有数据，只要有数据返回，就认为还有下一页
 */
@property (nonatomic, assign) BOOL                      moreData;

/**
 *  清空listArray，currentPage = 1
 */
- (void)reload;

/**
 *  清空listArray，currentPage = 1
 */
- (void)reloadOnView:(UIView *)view;

/**
 *  每页多少条数据，默认20
 */
- (NSUInteger)pageSize;

@end
