//
//  MBProgressHUD+Additions.m
//  AFNetworking的网络层方案设计
//
//  Created by 宇玄丶 on 2017/3/17.
//  Copyright © 2017年 北京116工作室. All rights reserved.
//

#import "MBProgressHUD+Additions.h"
#import <objc/runtime.h>

static MBProgressHUD  *s_progressHUD = nil;

@interface MBProgressHUD ()
@property(nonatomic,copy)NSNumber *hudCount;
@end

@implementation MBProgressHUD (Additions)

-(NSNumber *)hudCount
{
    return objc_getAssociatedObject(self,@selector(hudCount));
}

-(void)setHudCount:(NSNumber *)hudCount
{
    objc_setAssociatedObject(self,@selector(object),(id)hudCount,OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (void)showLoadingHUD:(NSString *)aString {
    UIWindow *window = mainWindow();
    [self showLoadingHUD:aString onView:window];
}

+ (void)showLoadingHUD:(NSString *)aString onView:(UIView *)view
{
    if (!view) {
        return;
    }
    if (!s_progressHUD) {
        s_progressHUD = [[MBProgressHUD alloc] initWithView:view];
        [view addSubview:s_progressHUD];
    }else{
        s_progressHUD.hudCount = @(s_progressHUD.hudCount.integerValue+1);
    }
    s_progressHUD.removeFromSuperViewOnHide = YES;
    s_progressHUD.animationType = MBProgressHUDAnimationZoom;
    if ([aString length]>0) {
        s_progressHUD.detailsLabelText = aString;
    }
    else s_progressHUD.detailsLabelText = nil;
    
    s_progressHUD.opacity = 0.7;
    [s_progressHUD show:YES];
}

+ (void)showMsgHUD:(NSString *)aString customImage:(UIImage *)customImage
{
    UIWindow *window = mainWindow();
    if (!window) {
        return;
    }
    [self hideLoadingHUD];
    MBProgressHUD *progressHUD = [[MBProgressHUD alloc] initWithView:window];
    [window addSubview:progressHUD];
    progressHUD.removeFromSuperViewOnHide = YES;
    progressHUD.animationType = MBProgressHUDAnimationZoom;
    if ([aString length]>0) {
        progressHUD.detailsLabelText = aString;
    }
    else progressHUD.detailsLabelText = nil;
    progressHUD.detailsLabelFont = [UIFont systemFontOfSize:14];
    progressHUD.opacity = 0.7;
    progressHUD.mode = MBProgressHUDModeCustomView;
    progressHUD.customView = [[UIImageView alloc] initWithImage:customImage];
    [progressHUD show:NO];
    [progressHUD hide:YES afterDelay:0.7];
}

+ (void)showMsgHUD:(NSString *)aString duration:(CGFloat)duration touchClose:(BOOL)close{
    UIWindow *window = mainWindow();
    [self showMsgHUD:aString onView:window duration:duration touchClose:close];
}

+ (void)showMsgHUD:(NSString *)aString onView:(UIView *)view duration:(CGFloat)duration touchClose:(BOOL)close
{
    if (!view) {
        return;
    }
    [self hideLoadingHUD];
    MBProgressHUD *progressHUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:progressHUD];
    progressHUD.animationType = MBProgressHUDAnimationZoom;
    progressHUD.detailsLabelText = safeString(aString);
    progressHUD.removeFromSuperViewOnHide = YES;
    progressHUD.opacity = 0.7;
    progressHUD.mode = MBProgressHUDModeText;
    [progressHUD show:NO];
    [progressHUD hide:YES afterDelay:duration];
    if (close) {
        [progressHUD handleClick:^(UIView *view) {
            [(MBProgressHUD*)view hide:YES];
        }];
    }
}

+ (void)showMsgHUD:(NSString *)aString
{
    [self showMsgHUD:aString duration:0.7];
}

+ (void)showMsgHUD:(NSString *)aString duration:(CGFloat)duration {
    [self showMsgHUD:aString duration:duration touchClose:NO];
}

+ (void)showMsgHUD:(NSString *)aString onView:(UIView *)view duration:(CGFloat)duration
{
    [self showMsgHUD:aString onView:view duration:duration touchClose:NO];
}

+ (void)hideLoadingHUD {
    if (s_progressHUD) {
        s_progressHUD.hudCount = @(s_progressHUD.hudCount.integerValue-1);
        if (s_progressHUD.hudCount.integerValue<1) {
            [s_progressHUD hide:YES];
            s_progressHUD = nil;
        }
    }
}

+ (void)updateLoadingHUD:(NSString*)progress {
    if (s_progressHUD) {
        s_progressHUD.detailsLabelText = progress;
    }
}

+ (void)showLoadingHUD:(NSString *)aString duration:(CGFloat)duration {
    UIWindow *window = mainWindow();
    if (!window) {
        return;
    }
    
    [self hideLoadingHUD];
    MBProgressHUD *progressHUD = [[MBProgressHUD alloc] initWithView:window];
    [window addSubview:progressHUD];
    progressHUD.animationType = MBProgressHUDAnimationZoom;
    progressHUD.detailsLabelText = aString;
    progressHUD.removeFromSuperViewOnHide = YES;
    progressHUD.opacity = 0.7;
    [progressHUD show:NO];
    [progressHUD hide:YES afterDelay:duration];
}

@end
