//
//  FZAutoLayout.m
//  Pods
//
//  Created by 周峰 on 2017/4/25.
//
//

#import "FZAutoLayout.h"
#import <objc/runtime.h>

@interface FZAutoLayout ()
@property(nonatomic,weak) UIView *target;
@property(nonatomic,weak) NSLayoutConstraint *lastModifiedConstraint;
@property(nonatomic,weak) UIView *lastModifiedConstraintReleatedView;
@property(nonatomic,weak) UIView *lastModifiedConstraintView;
@property(nonatomic,assign) FZAutoLayoutMask lastModifiedConstraintMask1;
@property(nonatomic,assign) FZAutoLayoutMask lastModifiedConstraintMask2;


@property(nonatomic,weak) NSLayoutConstraint *heightConstraint;
@property(nonatomic,weak) NSLayoutConstraint *widthConstraint;
@property(nonatomic,weak) NSLayoutConstraint *ratioConstraint;


- (void)resetLastModifiedConstraint;
- (void)resetHugAndCompressPriority;
@end

#pragma mark -

@implementation UIView (FZAutoLayout)

static char *fz_autoLayoutKey;
- (FZAutoLayout *)fz_autoLayout{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    FZAutoLayout *layout = objc_getAssociatedObject(self, &fz_autoLayoutKey);
    if (!layout) {
        layout = [[FZAutoLayout alloc] init];
        layout.target = self;
        objc_setAssociatedObject(self, &fz_autoLayoutKey, layout, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [layout resetLastModifiedConstraint];
    return layout;
}

- (NSArray<UIView *> *)fz_superViews{
    NSMutableArray *superviews = [NSMutableArray array];
    UIView *view = self;
    while (view) {
        [superviews addObject:view];
        view = view.superview;
    }
    return [superviews copy];
}

@end

#pragma mark -


@implementation FZAutoLayout

#pragma mark Public
- (FZAutoLayoutNone)reset{
    return ^id{
        for (UIView *view in self.target.fz_superViews) {
            for (NSLayoutConstraint *constraint in view.constraints) {
                if (constraint.firstItem == self.target) {
                    constraint.active = NO;
                }
            }
        }
        //重置自动大小
        [self resetHugAndCompressPriority];
        [self resetLastModifiedConstraint];
        return self;
    };
}

- (FZAutoLayoutNumber)priority{
    return ^id(CGFloat priority){
      
        [self updateConstraintWithPriority:priority
                                    offset:self.lastModifiedConstraint.constant
                                multiplier:self.lastModifiedConstraint.multiplier
                                     equal:self.lastModifiedConstraint.relation];
        
        return self;
    };
}
- (FZAutoLayoutNumber)offset{
    return ^id(CGFloat offset){
        
        if (self.ratioConstraint == self.lastModifiedConstraint
            || self.widthConstraint == self.lastModifiedConstraint
            || self.heightConstraint == self.lastModifiedConstraint) {
            
            //宽高比、高度、宽度无法设置offset
            return self;
        }
        [self updateConstraintWithPriority:self.lastModifiedConstraint.priority
                                    offset:offset
                                multiplier:self.lastModifiedConstraint.multiplier
                                     equal:self.lastModifiedConstraint.relation];
        return self;
    };
    
}
- (FZAutoLayoutNumber)multiplier{
    return ^id(CGFloat multiplier){
        
        if (self.ratioConstraint == self.lastModifiedConstraint
            || self.widthConstraint == self.lastModifiedConstraint
            || self.heightConstraint == self.lastModifiedConstraint) {
            
            //宽高比、高度、宽度无法设置multiplier
            return self;
        }
        
        [self updateConstraintWithPriority:self.lastModifiedConstraint.priority
                                    offset:self.lastModifiedConstraint.constant
                                multiplier:multiplier
                                     equal:self.lastModifiedConstraint.relation];
        
        return self;
    };
}
- (FZAutoLayoutNone)makeEqual{
    return ^id{
        [self updateConstraintWithPriority:self.lastModifiedConstraint.priority
                                    offset:self.lastModifiedConstraint.constant
                                multiplier:self.lastModifiedConstraint.multiplier
                                     equal:NSLayoutRelationEqual];
        
        return self;
    };
}
- (FZAutoLayoutNone)makeEqualOrGreaterThan{
    return ^id{
        [self updateConstraintWithPriority:self.lastModifiedConstraint.priority
                                    offset:self.lastModifiedConstraint.constant
                                multiplier:self.lastModifiedConstraint.multiplier
                                     equal:NSLayoutRelationGreaterThanOrEqual];
        
        return self;
    };
}
- (FZAutoLayoutNone)makeEqualOrLessThan{
    return ^id{
        [self updateConstraintWithPriority:self.lastModifiedConstraint.priority
                                    offset:self.lastModifiedConstraint.constant
                                multiplier:self.lastModifiedConstraint.multiplier
                                     equal:NSLayoutRelationLessThanOrEqual];
        return self;
    };
}

- (FZAutoLayoutEdge)edgeInsets{
    return ^id(UIEdgeInsets insets){
      
        UIView *superView = self.target.superview;
        if (superView) {
            self.topEqualTo(superView,FZAutoLayoutMaskTop).offset(insets.top)
            .leftEqualTo(superView,FZAutoLayoutMaskLeft).offset(insets.left)
            .rightEqualTo(superView,FZAutoLayoutMaskRight).offset(-insets.right)
            .bottomEqualTo(superView,FZAutoLayoutMaskBottom).offset(-insets.bottom);
        }        
        return self;
    };
}

- (FZAutoLayoutMaskTo)topEqualTo{
    return [self equalToViewWithMask:FZAutoLayoutMaskTop];
}
- (FZAutoLayoutMaskTo)leftEqualTo{
    return [self equalToViewWithMask:FZAutoLayoutMaskLeft];
}
- (FZAutoLayoutMaskTo)rightEqualTo{
    return [self equalToViewWithMask:FZAutoLayoutMaskRight];
}
- (FZAutoLayoutMaskTo)bottomEqualTo{
    return [self equalToViewWithMask:FZAutoLayoutMaskBottom];
}
- (FZAutoLayoutMaskTo)centerXEqualTo{
    return [self equalToViewWithMask:FZAutoLayoutMaskCenterX];
}
- (FZAutoLayoutMaskTo)centerYEqualTo{
    return [self equalToViewWithMask:FZAutoLayoutMaskCenterY];
}
- (FZAutoLayoutMaskTo)widthEqualTo{
    return [self equalToViewWithMask:FZAutoLayoutMaskWidth];
}
- (FZAutoLayoutMaskTo)heightEqualTo{
    return [self equalToViewWithMask:FZAutoLayoutMaskHeight];
}

- (FZAutoLayoutNumber)widthIs{
    return ^id(CGFloat width){
      
        if(self.widthConstraint){
            [self.target removeConstraint:self.widthConstraint];
            
        }
        [self setConstaintOfMask:FZAutoLayoutMaskWidth
                          toView:nil
                            mask:0
                          offset:width
                        priority:1000
                      multiplier:1.
                   equalRelation:NSLayoutRelationEqual];
        self.widthConstraint = self.lastModifiedConstraint;
        return self;
    };
}
- (FZAutoLayoutNumber)heightIs{
    return ^id(CGFloat height){
        
        if (self.heightConstraint) {
            [self.target removeConstraint:self.heightConstraint];
        }
        [self setConstaintOfMask:FZAutoLayoutMaskHeight
                          toView:nil
                            mask:0
                          offset:height
                        priority:1000
                      multiplier:1.
                   equalRelation:NSLayoutRelationEqual];
        self.heightConstraint = self.lastModifiedConstraint;
        return self;
    };
}
- (FZAutoLayoutNumber)aspectRatio{
    return ^id(CGFloat ratio){
        
        if(self.ratioConstraint){
            [self.target removeConstraint:self.ratioConstraint];
        }
        [self setConstaintOfMask:FZAutoLayoutMaskWidth
                          toView:self.target
                            mask:FZAutoLayoutMaskHeight
                          offset:0
                        priority:1000
                      multiplier:ratio
                   equalRelation:NSLayoutRelationEqual];
        self.ratioConstraint = self.lastModifiedConstraint;
        return self;
    };
}

- (FZAutoLayoutNone)autoWidth{
    return ^id{
        [self.target setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.target setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        return self;
    };
}
- (FZAutoLayoutNone)autoHeight{
    return ^id{
        [self.target setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self.target setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        return self;
    };
}


- (FZAutoLayoutNumber)animate{
    return ^id(CGFloat duration){
      
        [UIView animateWithDuration:duration animations:^{
            [self.target layoutIfNeeded];
        }];
        return self;
    };
}

#pragma mark Private
- (void)resetLastModifiedConstraint{
    self.lastModifiedConstraint = nil;
    self.lastModifiedConstraintView = nil;
    self.lastModifiedConstraintMask1 = 0;
    self.lastModifiedConstraintMask2 = 0;
    self.lastModifiedConstraintReleatedView = nil;
}

- (void)resetHugAndCompressPriority{
    [self.target setContentCompressionResistancePriority:750
                                                 forAxis:UILayoutConstraintAxisHorizontal];
    [self.target setContentHuggingPriority:251
                                   forAxis:UILayoutConstraintAxisHorizontal];
    [self.target setContentCompressionResistancePriority:750
                                                 forAxis:UILayoutConstraintAxisVertical];
    [self.target setContentHuggingPriority:251
                                   forAxis:UILayoutConstraintAxisVertical];
}


- (FZAutoLayoutMaskTo)equalToViewWithMask:(FZAutoLayoutMask)mask{
    return ^id(UIView *view,FZAutoLayoutMask mask2){
        
        [self setConstaintOfMask:mask
                          toView:view
                            mask:mask2
                          offset:0
                        priority:1000
                      multiplier:1.
                   equalRelation:NSLayoutRelationEqual];
        return self;
    };
}

- (void)deactiveLastModifierConstraint{
    [self.lastModifiedConstraint setActive:NO];//iOS 8 use this
}

- (void)setConstaintOfMask:(FZAutoLayoutMask) mask
                    toView:(UIView *)view
                      mask:(FZAutoLayoutMask) mask2
                    offset:(CGFloat) offset
                  priority:(CGFloat) priority
                multiplier:(CGFloat) multiplier
             equalRelation:(NSLayoutRelation) equal{
    
    self.lastModifiedConstraintMask1 = mask;
    self.lastModifiedConstraintMask2 = mask2;
    self.lastModifiedConstraintView = view;
    self.lastModifiedConstraintReleatedView = [self ancestorOfView:view];
    
    self.lastModifiedConstraint = [NSLayoutConstraint constraintWithItem:self.target
                                                               attribute:[self convertFromMask:mask]
                                                               relatedBy:equal
                                                                  toItem:view
                                                               attribute:[self convertFromMask:mask2]
                                                              multiplier:multiplier
                                                                constant:offset];
    
    UILayoutPriority uiPriority = priority*1.;
    if (uiPriority > UILayoutPriorityRequired) {
        uiPriority = UILayoutPriorityRequired;
    }
    if (uiPriority < 0) {
        uiPriority = 0;
    }
    self.lastModifiedConstraint.priority = uiPriority;
    [self.lastModifiedConstraintReleatedView addConstraint:self.lastModifiedConstraint];
}

- (void)updateConstraintWithPriority:(CGFloat) priority offset:(CGFloat)offset multiplier:(CGFloat) multiplier equal:(NSLayoutRelation) relation{
    
    if(!self.lastModifiedConstraint){//无最近设置的约束
        return;
    }
    
    BOOL isHeight = self.heightConstraint == self.lastModifiedConstraint;
    BOOL isWidth  = self.widthConstraint == self.lastModifiedConstraint;
    BOOL isRatio  = self.ratioConstraint == self.lastModifiedConstraint;
    
    [self deactiveLastModifierConstraint];
    
    [self setConstaintOfMask:self.lastModifiedConstraintMask1
                      toView:self.lastModifiedConstraintView
                        mask:self.lastModifiedConstraintMask2
                      offset:offset
                    priority:priority
                  multiplier:multiplier
               equalRelation:relation];
    
    if (isHeight) {
        self.heightConstraint = self.lastModifiedConstraint;
    }
    if (isWidth) {
        self.widthConstraint = self.lastModifiedConstraint;
    }
    if (isRatio) {
        self.ratioConstraint = self.lastModifiedConstraint;
    }
}

- (NSLayoutAttribute)convertFromMask:(FZAutoLayoutMask)mask{
    switch (mask) {
        case FZAutoLayoutMaskTop:
            return NSLayoutAttributeTop;
        case FZAutoLayoutMaskLeft:
            return NSLayoutAttributeLeft;
        case FZAutoLayoutMaskRight:
            return NSLayoutAttributeRight;
        case FZAutoLayoutMaskBottom:
            return NSLayoutAttributeBottom;
        case FZAutoLayoutMaskWidth:
            return NSLayoutAttributeWidth;
        case FZAutoLayoutMaskHeight:
            return NSLayoutAttributeHeight;
        case FZAutoLayoutMaskCenterX:
            return NSLayoutAttributeCenterX;
        case FZAutoLayoutMaskCenterY:
            return NSLayoutAttributeCenterY;
        case FZAutoLayoutMaskBaseline:
            return NSLayoutAttributeBaseline;
        case FZAutoLayoutMaskFirstBaseline:
            return NSLayoutAttributeFirstBaseline;
        case FZAutoLayoutMaskLastBaseline:
            return NSLayoutAttributeLastBaseline;
        default:{
            return NSLayoutAttributeNotAnAttribute;
        }
    }
}

- (UIView *)ancestorOfView:(UIView *)view{
    if (!view) {
        return self.target;
    }
    
    NSArray<UIView *> *mySuperViews = self.target.fz_superViews;
    for (UIView *superView in view.fz_superViews) {
        if ([mySuperViews containsObject:superView]) {
            return superView;
        }
    }
    return nil;
}

@end



