//
//  FZPageView.h
//  App
//
//  Created by 周峰 on 2017/5/5.
//
//

#import <UIKit/UIKit.h>
@class FZPageView;

/** FZPageView 代理协议 */
@protocol FZPageViewDelegate <NSObject>

@optional
/**
 *  @brief pageView切换到指定page时代理回调
 *
 *  @param pageView
 *  @param page           当前的page，从0开始
 *  @param viewController 当前page绑定的viewcontroller
 *  @param title          当前page绑定的title
 */
- (void)pageView:(FZPageView *)pageView pageChanged:(NSInteger) page viewController:(UIViewController *)viewController title:(NSString *)title;

@end

#pragma mark -
/** 主要样式编辑 */
@interface FZPageViewStyle : NSObject

/** 是否开启左右滑动切换页面,默认YES */
@property(nonatomic,assign,getter=isEnabledScrollSwitch) BOOL enableScrollSwitch;
/** 标题底部的线条指示器高度，默认2 */
@property(nonatomic,assign) CGFloat titleIndicatorHeight;

/** 是否允许调整单个标题宽度以充满整个横向区域，如果允许，在标题较少的情况下，可以等比分布标题，默认YES */
@property(nonatomic,assign,getter=isAdjustTitleWidth) BOOL adjustTitleWidth;

@property(nonatomic,strong) UIColor *titleBarBackgroundColor;///< 标题栏背景颜色,默认 0XFFFFFF
@property(nonatomic,strong) UIColor *titleNormalColor;///< 标题基本颜色，默认0xa2a2a2
@property(nonatomic,strong) UIColor *titleSelectedColor;///< 标题选中颜色，默认0xFF4500
@property(nonatomic,strong) UIColor *partingLineColor;///< 标题与内容分割线颜色，默认0xebebeb

@property(nonatomic,strong) UIFont *titleNormalFont;///< 标题字体，默认systemFontWithSize:13
@property(nonatomic,assign) CGFloat fontScaleFactor;///< 标题选中时字体放大倍数，默认1.2

@end

#pragma mark -

/**
 *  @brief 仿网易新闻的标题-内容滚动切换控件，可以自定义标题栏的颜色和变化规则
 */
@interface FZPageView : UIView

/** 样式编辑器 */
@property(nonatomic,strong,readonly) FZPageViewStyle *style;

@property(nonatomic,weak) id<FZPageViewDelegate> delegate;
/** 当前页面中缓存的所有vc，顺序与page对应 */
@property(nonatomic,readonly) NSArray<UIViewController *> *controllers;
/** 当前页面位置 */
@property(nonatomic,assign) NSInteger currentPage;

/** 删除指定的视图 */
- (void)removeViewController:(UIViewController *)vc;

/** 添加滚动视图 */
- (void)addViewController:(UIViewController *)vc forTitle:(NSString *)title;

/** 滚动到指定视图 */
- (void)setPage:(NSInteger) page animate:(BOOL)animate;


@end
