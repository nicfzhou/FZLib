//
//  FZPageView.m
//  App
//
//  Created by 周峰 on 2017/5/5.
//
//


#import "FZAutoLayout.h"
#import "ReactiveCocoa.h"
#import "FZPageView.h"


@implementation FZPageViewStyle

+ (instancetype)defautlStyle{
    FZPageViewStyle *style = [[FZPageViewStyle alloc] init];
    style.enableScrollSwitch = YES;
    style.titleIndicatorHeight = 2;
    style.adjustTitleWidth = YES;
    style.titleBarBackgroundColor = [UIColor whiteColor];
    style.titleNormalColor = [UIColor colorWithRed:162/255. green:162/255. blue:162/255. alpha:1];
    style.titleSelectedColor = [UIColor colorWithRed:1 green:69/255. blue:0 alpha:1];
    style.partingLineColor = [UIColor colorWithRed:235/255. green:235/255. blue:235/255. alpha:1];
    style.titleNormalFont = [UIFont systemFontOfSize:13];
    style.fontScaleFactor = 1.2;
    return style;
}

@end


#pragma mark -

@interface FZPageView ()<UICollectionViewDataSource>
@property(nonatomic,strong) FZPageViewStyle *style;
@property(nonatomic,strong) NSArray<NSString *> *titleTexts;
@property(nonatomic,strong) NSMutableDictionary<NSString *,UIControl *> *titleControlMap;
@property(nonatomic,strong) NSArray<UIViewController *> *controllers;
@property(nonatomic,strong) UIScrollView *titleControlsStrollView;///< 顶部标题
@property(nonatomic,strong) UIView *partingLineView;///< 分割线
@property(nonatomic,strong) UICollectionView *contentCollectionView;///< 内容区域
@property(nonatomic,strong) UIView *titleIndicatorView;///< 指示器

@end

@implementation FZPageView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self fz_bindingData];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self fz_bindingData];
    }
    return self;
}

- (void)setupSubviews{
    //标题栏
    self.titleControlsStrollView = ^id{
        
        UIScrollView *scrollview = [[UIScrollView alloc] init];
        scrollview.showsVerticalScrollIndicator = NO;
        scrollview.showsHorizontalScrollIndicator = NO;
        [self addSubview:scrollview];
        scrollview.fz_autoLayout
        .heightIs(40)
        .widthEqualToView(self)
        .topEqualToView(self)
        .leftEqualToView(self);
        return scrollview;
    }();
    self.titleControlMap = [NSMutableDictionary dictionary];
    
    //页面page指示器
    self.titleIndicatorView = ^id{
        
        UIView *view = [[UIView alloc] init];
        [self addSubview:view];
        return view;
    }();
    
    //分割线
    self.partingLineView = ^id{
        
        UIView *view = [[UIView alloc] init];
        [self addSubview:view];
        view.fz_autoLayout
        .heightIs(1)
        .topSpaceToView(self.titleControlsStrollView).offset(-1)
        .leftEqualToView(self)
        .rightEqualToView(self);
        return view;
    }();
    
    //内容栏
    self.contentCollectionView = ^id{
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor whiteColor];
        [self addSubview:collectionView];
        collectionView.fz_autoLayout
        .topSpaceToView(self.partingLineView)
        .leftEqualToView(self)
        .rightEqualToView(self)
        .bottomEqualToView(self);
        collectionView.dataSource = self;
        collectionView.pagingEnabled = YES;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        [collectionView registerClass:[UICollectionViewCell class]
           forCellWithReuseIdentifier:@"content"];
        RAC(layout,itemSize) = [[RACObserve(collectionView, bounds) map:^id(NSValue *x){
            return [NSValue valueWithCGSize:x.CGRectValue.size];
        }] distinctUntilChanged];//动态变化itemSize
        return collectionView;
    }();
    
}

- (void)fz_bindingData{
    @weakify(self)
    self.style = [FZPageViewStyle defautlStyle];//设置默认样式
    [self setupSubviews];
    
    //是否可以滚动
    RAC(self,contentCollectionView.scrollEnabled) = RACObserve(self, style.enableScrollSwitch);
    //页面滚动信号
    RACSignal *pageSignal = [[RACObserve(self, contentCollectionView.contentOffset) combineLatestWith:RACObserve(self, contentCollectionView.bounds)] map:^id(RACTuple *t){
        //当前page
        CGPoint offset = ((NSValue *)t.first).CGPointValue;
        CGRect rect = ((NSValue *)t.second).CGRectValue;
        CGFloat page = offset.x / rect.size.width;
        return @(page);
    }];
    //当前页面位置
    RAC(self,currentPage) = [[[pageSignal filter:^BOOL(NSNumber *x){
        return (int)(x.floatValue*100) % 100 == 0;
    }] map:^id(NSNumber *x){
        return @(x.integerValue);
    }] distinctUntilChanged];
    //代理回调
    [[[RACObserve(self, currentPage) distinctUntilChanged] throttle:.5] subscribeNext:^(NSNumber *x){

        @strongify(self)
        if(self.delegate){
            [self.delegate pageView:self
                        pageChanged:x.integerValue
                     viewController:self.controllers[x.integerValue]
                              title:self.titleTexts[x.integerValue]];
        }
    }];
    //分割线颜色
    RAC(self,partingLineView.backgroundColor) = RACObserve(self, style.partingLineColor);
    //指示器颜色
    RAC(self,titleIndicatorView.backgroundColor) = RACObserve(self, style.titleSelectedColor);
    //指示器frame
    [[RACSignal combineLatest:@[
                               [RACObserve(self, style.titleIndicatorHeight)
                                distinctUntilChanged],
                               pageSignal,
                               [RACObserve(self, style.titleNormalFont)
                                distinctUntilChanged],
                               [RACObserve(self, style.fontScaleFactor)
                                distinctUntilChanged],
                               [RACObserve(self, titleControlsStrollView.contentOffset)
                                distinctUntilChanged],
                               [RACObserve(self, titleControlsStrollView.contentSize)
                                distinctUntilChanged]
                               ]]
     subscribeNext:^(RACTuple *t){
     
         @strongify(self)
         CGFloat height = [(NSNumber *)t.first doubleValue];
         CGFloat page = ((NSNumber *)t.second).floatValue;
         UIFont *font = t.third;
         CGFloat factor = ((NSNumber *)t.fourth).floatValue;
         
         if (isnan(page)) {
             return ;
         }
         int page1 = floor(page);//当前滚动中的page的左右pageIndex
         int page2 = page1 + 1;
         
         
         CGRect(^calcRect)(int) = ^CGRect(int idx){
             
             if (idx < 0 ) {
                 idx = 0;
             }
             if (idx >= self.titleTexts.count) {
                 idx = (int)self.titleTexts.count - 1;
             }
             NSString *text = self.titleTexts[idx];
             if(!text){
                 return CGRectZero;
             }
             UIControl *control = self.titleControlMap[text];
             if (!control) {
                 return CGRectZero;
             }
             CGRect rect = [self convertRect:control.frame fromView:control.superview];
             rect.origin.y = rect.origin.y + rect.size.height - height - 1;//排除分割线高度
             rect.size.height = height;
             CGFloat textWidth = [text sizeWithAttributes:@{NSFontAttributeName:font}].width*factor;
             rect.origin.x += (rect.size.width - textWidth)*.5;
             rect.size.width = textWidth;
             return rect;
         };
         CGRect rect1 = calcRect(page1),rect2 = calcRect(page2);
         
         CGFloat offsetFactor = page - page1;
         CGFloat offsetX = (rect2.origin.x - rect1.origin.x) * offsetFactor;
         CGFloat offsetY = (rect2.origin.y - rect1.origin.y) * offsetFactor;
         CGFloat offsetW = (rect2.size.width - rect1.size.width) * offsetFactor;
         CGFloat offsetH = (rect2.size.height - rect1.size.height) * offsetFactor;
         
         CGRect rect = CGRectMake(rect1.origin.x + offsetX,
                                  rect1.origin.y + offsetY,
                                  rect1.size.width + offsetW,
                                  rect1.size.height + offsetH);
         self.titleIndicatorView.frame = rect;
     }];
    
    //内容刷新
    RACSignal *contentSizeSignal = [[[RACObserve(self, contentCollectionView.bounds) ignore:nil] map:^id(NSValue *x){
        return [NSValue valueWithCGSize:x.CGRectValue.size];
    }] distinctUntilChanged];
    [[RACSignal combineLatest:@[
                               [RACObserve(self, controllers) throttle:.5],
                               [contentSizeSignal throttle:.5]
                               ]]
     subscribeNext:^(id x){
         @strongify(self)
         [self.contentCollectionView reloadData];
     }];
    //标题位置刷新 - 使其尽量在居中位置显示
    [[RACSignal combineLatest:@[
                               [[RACObserve(self, currentPage) distinctUntilChanged] delay:.1],
                               [RACObserve(self, titleControlsStrollView.contentSize) distinctUntilChanged]
                               ]]
     subscribeNext:^(RACTuple *t){
    
         @strongify(self)
         int page = ((NSNumber *)t.first).intValue;
         NSString *text = self.titleTexts[page];
         if(!text){
             return;
         }
         UIControl *control = self.titleControlMap[text];
         if (!control) {
             return;
         }
         
         CGRect rect = control.frame;
         CGFloat width = self.titleControlsStrollView.bounds.size.width;
         CGFloat minOffsetX = 0,maxOffsetX = self.titleControlsStrollView.contentSize.width - width;
         CGFloat offsetX = rect.origin.x + rect.size.width * .5 - width * .5;//使其居中的偏移量
         if (offsetX < minOffsetX) {//检查最大最小偏移量范围
             offsetX = minOffsetX;
         }
         if (offsetX >= maxOffsetX) {
             offsetX = maxOffsetX;
         }
         
         [self.titleControlsStrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];

     }];
    
    
    //标题内容刷新
    [[RACSignal combineLatest:@[
                               [RACObserve(self, titleTexts) throttle:.5],
                               [RACObserve(self, titleControlsStrollView.bounds) throttle:.5],
                               RACObserve(self, style.adjustTitleWidth),
                               RACObserve(self, style.titleNormalFont),
                               RACObserve(self, style.fontScaleFactor)
                               ]]
     subscribeNext:^(RACTuple *t){
     
         @strongify(self)
         NSArray<NSString *> *texts = t.first;
         CGRect rect = ((NSValue *)t.second).CGRectValue;
         //title最小宽度，如果实际宽度超过这个，则以实际宽度为准
         CGFloat textMinWidth = rect.size.width / texts.count;
         if(!self.style.adjustTitleWidth){
             textMinWidth = 0;//已实际宽度为准
         }
         
         //清楚已经不存在的title对应的UIControl
         for(NSString *key in [self.titleControlMap.allKeys filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *key,NSDictionary *map){
             return ![texts containsObject:key];
         }]]){
             UIControl *control = self.titleControlMap[key];
             [control removeFromSuperview];
             [self.titleControlMap removeObjectForKey:key];
         }

         
         __block CGFloat xOffset = 0;
         [texts enumerateObjectsUsingBlock:^(NSString *text,NSUInteger idx,BOOL *stop){
             
             CGSize textExpectedSize = ^CGSize{
             
                 UIFont *font = self.style.titleNormalFont;
                 CGSize size = [text sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:font.fontName size:font.pointSize * MAX(1.0,self.style.fontScaleFactor)]}];
                 size.width += 40;
                 if (size.width < textMinWidth) {
                     size.width = textMinWidth;
                 }
                 return size;
             }();
             
             CGRect controlExpectedFrame = CGRectMake(xOffset, 0, textExpectedSize.width, 40);
             xOffset += controlExpectedFrame.size.width;
             
             UIControl *control = ^id{
             
                 UIControl *target = self.titleControlMap[text];
                 if (!target) {
                     target = [[UIControl alloc] init];
                     self.titleControlMap[text] = target;
                     [self.titleControlsStrollView addSubview:target];
                     //点击选中
                     [[target rac_signalForControlEvents:UIControlEventTouchUpInside]
                      subscribeNext:^(id x){
                         
                         @strongify(self)
                         NSInteger page = [self.titleTexts indexOfObject:text];
                         [self setPage:page animate:YES];
                     }];
                 }
                 //update frame
                 target.frame = controlExpectedFrame;
                 return target;
             }();
             
             CATextLayer *textLayer = ^id{
             
                 CATextLayer *layer = (CATextLayer *)control.layer.sublayers[0];
                 if (!layer) {
                     layer = [CATextLayer layer];
                     layer.contentsScale = [UIScreen mainScreen].scale;
                     layer.string = text;
                     layer.alignmentMode = kCAAlignmentCenter;
                     [control.layer addSublayer:layer];
                     
                     //当前页面page和title期望的page偏移程度：0-1 ，0表示没有偏移，1表示完全偏移
                     RACSignal *factorSignal = [pageSignal map:^id(NSNumber *x)
                     {
                         @strongify(self)
                         CGFloat page = x.floatValue;
                         NSInteger idx = [self.titleTexts indexOfObject:text];
                         CGFloat factor = ((int)(fabs(page - idx) * 100))/100.;//只要2位小数
                         if (factor > 1) {//最大为1
                             factor = 1;
                         }
                         return @(factor);
                     }];
                     
                     [[[RACSignal combineLatest:@[
                                                [factorSignal distinctUntilChanged],
                                                [RACObserve(self, style.titleSelectedColor)
                                                 distinctUntilChanged],
                                                [RACObserve(self, style.titleNormalColor)
                                                 distinctUntilChanged],
                                                [RACObserve(self, style.fontScaleFactor)
                                                 distinctUntilChanged],
                                                [RACObserve(self, style.titleNormalFont)
                                                 distinctUntilChanged]
                                                ]] takeUntil:control.rac_willDeallocSignal]
                      subscribeNext:^(RACTuple *t)
                     {
                         CGFloat factor  = [(NSNumber *)t.first floatValue];
                         UIColor *colorNormal = t.third;
                         UIColor *colorSelected = t.second;
                         //关闭隐式动画
                         [CATransaction begin];
                         [CATransaction setDisableActions:YES];
                         CGFloat r1,g1,b1,r2,g2,b2;
                         [colorSelected getRed:&r1 green:&g1 blue:&b1 alpha:NULL];
                         [colorNormal getRed:&r2 green:&g2 blue:&b2 alpha:NULL];
                         float r = fabs(r1 - ((r1 - r2) * factor));
                         float g = fabs(g1 - ((g1 - g2) * factor));
                         float b = fabs(b1 - ((b1 - b2) * factor));
                         UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:1];
                         layer.foregroundColor = color.CGColor;
                         
                         UIFont *font = (UIFont *)t.fifth;
                         //字体大小
                         CGFloat minFontSize = [font pointSize];
                         CGFloat maxFontSize = minFontSize * ((NSNumber *)t.fourth).floatValue;
                         layer.fontSize = maxFontSize - ((maxFontSize - minFontSize) * factor);
                         //字体类型
                         CFStringRef fontName = (__bridge CFStringRef)(font.fontName);
                         CGFontRef fontRef = CGFontCreateWithFontName(fontName);
                         layer.font = fontRef;
                         //layer的位置也要微调，以便垂直居中
                         font = [UIFont fontWithName:font.fontName size:layer.fontSize];
                         CGSize size = [text sizeWithAttributes:@{NSFontAttributeName:font}];
                         layer.frame = CGRectMake(0,
                                                  (40 - size.height) * .5,
                                                  controlExpectedFrame.size.width,
                                                  size.height);
                         [CATransaction commit];
                     }];
                 }
                 return layer;
             }();
         }];
         
         self.titleControlsStrollView.contentSize = CGSizeMake(xOffset, rect.size.height);
     }];
    
}


#pragma mark Public
/** 删除指定的视图 */
- (void)removeViewController:(UIViewController *)vc{
    
    NSInteger idx = [self.controllers indexOfObject:vc];
    if (idx == NSNotFound) {
        return;
    }
    
    self.titleTexts = ^id{
        
        NSMutableArray *x = [self.titleTexts mutableCopy];
        [x removeObjectAtIndex:idx];
        return  [x copy];
    }();
    
    self.controllers = ^id{
        
        NSMutableArray *x = [self.controllers mutableCopy];
        [x removeObjectAtIndex:idx];
        return  [x copy];
    }();
    
}

/** 添加滚动视图 */
- (void)addViewController:(UIViewController *)vc forTitle:(NSString *)title{
    self.titleTexts = ^id{
    
        NSMutableArray *x = [self.titleTexts mutableCopy]?:[NSMutableArray array];
        [x addObject:title];
        return  [x copy];
    }();
    
    self.controllers = ^id{
        
        NSMutableArray *x = [self.controllers mutableCopy]?:[NSMutableArray array];
        [x addObject:vc];
        return  [x copy];
    }();
}

/** 滚动到指定视图 */
- (void)setPage:(NSInteger) page animate:(BOOL)animate{
    CGRect rect = self.contentCollectionView.bounds;
    rect.origin.x = page * rect.size.width;
    [self.contentCollectionView scrollRectToVisible:rect animated:animate];
}


#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.controllers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"content" forIndexPath:indexPath];
    UIViewController *vc = self.controllers[indexPath.row];
    vc.automaticallyAdjustsScrollViewInsets = NO;
    for (UIView *view in [cell.contentView.subviews copy]) {
        [view removeFromSuperview];
    }
    vc.view.frame = cell.contentView.bounds;
    [cell.contentView addSubview:vc.view];
    return cell;
}

- (void)dealloc{
    
}

@end
