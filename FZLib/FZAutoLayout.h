//
//  FZAutoLayout.h
//  Pods
//
//  Created by 周峰 on 2017/4/25.
//
//

#import <Foundation/Foundation.h>
@class FZAutoLayout;

typedef NS_ENUM(NSInteger,FZAutoLayoutMask) {
    FZAutoLayoutMaskTop = 1,
    FZAutoLayoutMaskLeft,
    FZAutoLayoutMaskRight,
    FZAutoLayoutMaskBottom,
    FZAutoLayoutMaskWidth,
    FZAutoLayoutMaskHeight,
    FZAutoLayoutMaskCenterX,
    FZAutoLayoutMaskCenterY,
    FZAutoLayoutMaskBaseline,
    FZAutoLayoutMaskFirstBaseline,
    FZAutoLayoutMaskLastBaseline,
};


typedef FZAutoLayout*(^FZAutoLayoutMaskTo)(UIView *target,FZAutoLayoutMask mask);
typedef FZAutoLayout*(^FZAutoLayoutNumber)(CGFloat);
typedef FZAutoLayout*(^FZAutoLayoutEdge)(UIEdgeInsets);
typedef FZAutoLayout*(^FZAutoLayoutNone)();

@interface FZAutoLayout : NSObject

/** 重置所有对本身的约束，其他view相当于本身的约束不会被清楚 */
- (FZAutoLayoutNone)reset;

- (FZAutoLayoutNumber)priority;
- (FZAutoLayoutNumber)offset;
- (FZAutoLayoutNumber)multiplier;
- (FZAutoLayoutNone)makeEqual;
- (FZAutoLayoutNone)makeEqualOrGreaterThan;
- (FZAutoLayoutNone)makeEqualOrLessThan;



- (FZAutoLayoutEdge)edgeInsets;
- (FZAutoLayoutMaskTo)topEqualTo;
- (FZAutoLayoutMaskTo)leftEqualTo;
- (FZAutoLayoutMaskTo)rightEqualTo;
- (FZAutoLayoutMaskTo)bottomEqualTo;
- (FZAutoLayoutMaskTo)centerXEqualTo;
- (FZAutoLayoutMaskTo)centerYEqualTo;
- (FZAutoLayoutMaskTo)widthEqualTo;
- (FZAutoLayoutMaskTo)heightEqualTo;

- (FZAutoLayoutNumber)widthIs;
- (FZAutoLayoutNumber)heightIs;
- (FZAutoLayoutNumber)aspectRatio;/**< 宽高比 */
- (FZAutoLayoutNone)autoWidth;
- (FZAutoLayoutNone)autoHeight;



- (FZAutoLayoutNumber)animate;

@end


@interface UIView (FZAutoLayout)

- (FZAutoLayout *)fz_autoLayout;


@end
