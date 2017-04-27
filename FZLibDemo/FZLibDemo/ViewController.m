//
//  ViewController.m
//  FZLibDemo
//
//  Created by 周峰 on 2017/4/24.
//
//

#import "ViewController.h"
#import "FZAutoLayout.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIView *view = [self randomView];
    [self.view addSubview:view];
    view.fz_autoLayout.topEqualTo(self.view,FZAutoLayoutMaskTop).offset(20)
    .leftEqualTo(self.view,FZAutoLayoutMaskLeft).offset(20)
    .widthIs(100)
    .aspectRatio(1/2.);
    
    
    UIView *view2 = [self randomView];
    [self.view addSubview:view2];
    view2.fz_autoLayout.topEqualTo(view,FZAutoLayoutMaskBottom).offset(20)
    .leftEqualTo(view,FZAutoLayoutMaskLeft)
    .widthIs(100)
    .heightIs(50);
    
    UIView *view3 = [self randomView];
    [self.view addSubview:view3];
    view3.fz_autoLayout.topEqualTo(view2,FZAutoLayoutMaskTop)
    .leftEqualTo(view2,FZAutoLayoutMaskRight).offset(20)
    .widthEqualTo(view2,FZAutoLayoutMaskWidth).multiplier(.5)
    .heightEqualTo(view2,FZAutoLayoutMaskHeight).multiplier(2);
    
    UIView *view4 = [self randomView];
    [view addSubview:view4];
    view4.fz_autoLayout.topEqualTo(view,FZAutoLayoutMaskTop).offset(10)
    .leftEqualTo(view,FZAutoLayoutMaskLeft)
    .aspectRatio(1/2.)
    .aspectRatio(1/3.)
    .bottomEqualTo(view,FZAutoLayoutMaskBottom);
    
    
    UIView *view5 = [self randomView];
    [view addSubview:view5];
    view5.fz_autoLayout.edgeInsets(UIEdgeInsetsMake(10, 10, 10, 10));
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"是打发大大师傅阿斯蒂芬阿斯蒂芬撒旦法沙发阿斯蒂芬暗室逢灯阿凡达阿道夫按时";
    [self.view addSubview:label];
    label.fz_autoLayout.topEqualTo(view4,FZAutoLayoutMaskBottom).offset(10)
    .leftEqualTo(view4,FZAutoLayoutMaskLeft);
    
    UILabel *label2 = [[UILabel alloc] init];
    label2.text = @"是打发大大师傅阿斯蒂芬阿斯蒂芬撒旦法沙发阿斯蒂芬暗室逢灯阿凡达阿道夫按时";
    label2.numberOfLines = 0;
    [self.view addSubview:label2];
    label2.fz_autoLayout.topEqualTo(label,FZAutoLayoutMaskBottom).offset(10)
    .leftEqualTo(label,FZAutoLayoutMaskLeft)
    .widthIs(100)
    .autoHeight();
    
    UILabel *label3 = [[UILabel alloc] init];
    label3.text = @"是打发大大师傅阿斯蒂芬阿斯蒂芬撒旦法沙发阿斯蒂芬暗室逢灯阿凡达阿道夫按时";
    label3.numberOfLines = 0;
    [self.view addSubview:label3];
    label3.fz_autoLayout.topEqualTo(label2,FZAutoLayoutMaskBottom).offset(10)
    .leftEqualTo(label,FZAutoLayoutMaskLeft)
    .autoWidth()
    .heightIs(100);
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIView *)randomView{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [self randomColor];
    return view;
}

- (UIColor *)randomColor{
    return [UIColor colorWithRed:(arc4random()%256)/255. green:(arc4random()%256)/255. blue:(arc4random()%256)/255. alpha:1];
}

@end
