//
//  ViewController.m
//  FZLibDemo
//
//  Created by 周峰 on 2017/4/24.
//
//

#import "ViewController.h"
#import "FZAutoLayout.h"
#import "FZPageView.h"
#import "ReactiveCocoa.h"

@interface ViewController ()<FZPageViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    FZPageView *view = [[FZPageView alloc] init];
    [self.view addSubview:view];
    view.fz_autoLayout.edgeInsets(20,0,0,0);
    
    view.delegate = self;
    [view addViewController:[self randomVC] forTitle:@"标题标题1"];
    [view addViewController:[self randomVC] forTitle:@"标题2"];
    [view addViewController:[self randomVC] forTitle:@"标题标题标题3"];
    [view addViewController:[self randomVC] forTitle:@"标题4"];
    [view addViewController:[self randomVC] forTitle:@"t5"];
    [view addViewController:[self randomVC] forTitle:@"t6"];
    [view addViewController:[self randomVC] forTitle:@"t7"];
    
    view.style.titleSelectedColor = [UIColor redColor];
    view.style.adjustTitleWidth = NO;
    view.style.titleNormalFont = [UIFont boldSystemFontOfSize:15];
    view.style.partingLineColor = [UIColor blackColor];
    NSLog(@"%d %d",view.style.isAdjustTitleWidth,view.style.isEnabledScrollSwitch);
    
    @weakify(view)
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 100, 100, 44);
    btn.backgroundColor = [UIColor redColor];
    [btn setTitle:@" 删除 " forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *x){
//        @strongify(view);
        [view removeFromSuperview];
        [x removeFromSuperview];
    
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIView *)randomView{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [self randomColor];
    [self.view addSubview:view];
    return view;
}

- (UIColor *)randomColor{
    return [UIColor colorWithRed:(arc4random()%256)/255. green:(arc4random()%256)/255. blue:(arc4random()%256)/255. alpha:1];
}


- (UIViewController *)randomVC{
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [self randomColor];
    return vc;
}

- (void)pageView:(FZPageView *)pageView pageChanged:(NSInteger)page viewController:(UIViewController *)viewController title:(NSString *)title{
    NSLog(@"%@ - %@",title,@(page));
}
@end
