//
//  ServerMacro.h
//  AFNetworking的网络层方案设计
//
//  Created by 宇玄丶 on 2017/3/17.
//  Copyright © 2017年 北京116工作室. All rights reserved.
//

#ifndef ServerMacro_h
#define ServerMacro_h

#if defined APP_DEBUG

//-----------------------------------  测试环境  ------------------------------------

#define Service_Address     @""

// **********************************************************************************

#else

//-----------------------------------  生产环境  ------------------------------------

#define Service_Address     @""

#endif

#define BaseUrl     Service_Address@""


#define Login_Url                       @""
//商品列表
#define Goods_List_Url                  @"/mall/shopList"
//加入购物车
#define Add_To_Cart_Url                 @"/mall/addToCart"


#endif /* ServerMacro_h */
