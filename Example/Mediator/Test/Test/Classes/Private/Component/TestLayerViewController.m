//
//  TestLayerViewController.m
//  Example
//
//  Created by wuyong on 16/11/13.
//  Copyright © 2016年 ocphp.com. All rights reserved.
//

#import "TestLayerViewController.h"

@interface TestLayerView : UIView

@end

@implementation TestLayerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [Theme backgroundColor];
        
        [self testLayer];
        [self progressLayer];
        [self dashLayer];
    }
    return self;
}

- (void)testLayer
{
    // 宿主图层显示图片
    UIImage *image = [TestBundle imageNamed:@"public_icon"];
    CALayer *imageLayer = [[CALayer alloc] init];
    imageLayer.frame = CGRectMake(90, 70, 20, 40);
    imageLayer.contents = (__bridge id)image.CGImage;
    // 设置图片显示模式
    imageLayer.contentsGravity = kCAGravityCenter;
    // 需要设置为屏幕Scale，默认1.0
    // imageLayer.contentsScale = image.scale;
    imageLayer.contentsScale = [UIScreen mainScreen].scale;
    // 不超过边界
    imageLayer.masksToBounds = YES;
    // 单位
    imageLayer.contentsRect = CGRectMake(0, 0, 0.5, 0.5);
    // 固定边框和拉伸区域，类似resizableImageWithCapInsets
    imageLayer.contentsCenter = CGRectMake(0.25, 0.25, 0.5, 0.5);
    // delegate，仅当自定义Layer时使用，默认UIView为CALayer的代理
    // imageLayer.delegate = self;
    [self.layer addSublayer:imageLayer];
    
    // 拼接图片
    imageLayer = [[CALayer alloc] init];
    imageLayer.frame = CGRectMake(110, 70, 20, 40);
    imageLayer.contents = (__bridge id)image.CGImage;
    imageLayer.contentsGravity = kCAGravityCenter;
    imageLayer.contentsScale = [UIScreen mainScreen].scale;
    imageLayer.masksToBounds = YES;
    imageLayer.contentsRect = CGRectMake(0.5, 0.5, 0.5, 0.5);
    [self.layer addSublayer:imageLayer];
}

- (void)progressLayer
{
    // 单色进度
    CAShapeLayer *layer = [self.fw addCircleLayer:CGRectMake(20, 330, 50, 50) degree:-90 progress:1.0 strokeColor:[UIColor orangeColor] strokeWidth:4];
    [self.fw strokeWithLayer:layer duration:2.0 completion:NULL];
    
    // 双色进度
    layer = [self.fw addCircleLayer:CGRectMake(90, 330, 50, 50) degree:-90 progress:0.6 progressColor:[UIColor redColor] strokeColor:[UIColor orangeColor] strokeWidth:4];
    [self.fw strokeWithLayer:layer duration:2.0 completion:NULL];
    
    // 渐变进度
    CALayer *gradientLayer = [self.fw addCircleLayer:CGRectMake(160, 330, 50, 50) degree:-90 progress:1.0 gradientBlock:^(CALayer *layer) {
        CAGradientLayer *subLayer = [CAGradientLayer layer];
        subLayer.frame = CGRectMake(0, 0, 50, 50);
        subLayer.colors = @[(id)[UIColor redColor].CGColor, (id)[UIColor greenColor].CGColor, (id)[UIColor blueColor].CGColor];
        subLayer.locations = @[@0.25, @0.5, @0.75];
        subLayer.startPoint = CGPointMake(0, 0);
        subLayer.endPoint = CGPointMake(0, 1);
        [layer addSublayer:subLayer];
    } strokeColor:[UIColor orangeColor] strokeWidth:4];
    [self.fw strokeWithLayer:(CAShapeLayer *)gradientLayer.mask duration:2.0 completion:NULL];
    
    [self.fw addCircleLayer:CGRectMake(230, 330, 50, 50) degree:-90 progress:1.0 strokeColor:[UIColor orangeColor] strokeWidth:4];
    gradientLayer = [self.fw addCircleLayer:CGRectMake(230, 330, 50, 50) degree:-90 progress:1.0 gradientBlock:NULL strokeColor:[UIColor orangeColor] strokeWidth:4];
    CAGradientLayer *leftLayer = [CAGradientLayer.fw gradientLayer:CGRectMake(0, 0, 25, 50) colors:@[(id)[UIColor yellowColor].CGColor, (id)[UIColor redColor].CGColor] locations:@[@0.33, @0.66] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(0, 1)];
    [gradientLayer addSublayer:leftLayer];
    CAGradientLayer *rightLayer = [CAGradientLayer.fw gradientLayer:CGRectMake(25, 0, 25, 50) colors:@[(id)[UIColor yellowColor].CGColor, (id)[UIColor blueColor].CGColor] locations:@[@0.33, @0.66] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(0, 1)];
    [gradientLayer addSublayer:rightLayer];
    [self.fw strokeWithLayer:(CAShapeLayer *)gradientLayer.mask duration:2.0 completion:NULL];
}

- (void)dashLayer
{
    UIView *dashView = [[UIView alloc] initWithFrame:CGRectMake(20, 400, 50, 50)];
    [self addSubview:dashView];
    [dashView.fw addDashLayer:CGRectMake(0, 25, 50, 1) lineLength:5 lineSpacing:5 lineColor:[UIColor orangeColor]];
    
    dashView = [[UIView alloc] initWithFrame:CGRectMake(90, 400, 50, 50)];
    [self addSubview:dashView];
    [dashView.fw addDashLayer:CGRectMake(25, 0, 1, 50) lineLength:5 lineSpacing:5 lineColor:[UIColor orangeColor]];
    
    dashView = [[UIView alloc] initWithFrame:CGRectMake(160, 400, 50, 50)];
    [self addSubview:dashView];
    [dashView.fw addDashLayer:CGRectMake(12.5, 25, 25, 2) lineLength:5 lineSpacing:5 lineColor:[UIColor orangeColor]];
    
    dashView = [[UIView alloc] initWithFrame:CGRectMake(230, 400, 50, 50)];
    [self addSubview:dashView];
    [dashView.fw addDashLayer:CGRectMake(25, 12.5, 2, 25) lineLength:5 lineSpacing:5 lineColor:[UIColor orangeColor]];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 绘制曲线
    {
        // 三次贝塞尔控制点
        CGContextSetLineWidth(context, 2);
        [[UIColor orangeColor] setStroke];
        CGContextMoveToPoint(context, 10, 60);
        CGContextAddCurveToPoint(context, 30, 30, 50, 90, 70, 30);
        CGContextStrokePath(context);
        
        // 二次贝塞尔控制点
        CGContextMoveToPoint(context, 90, 60);
        CGContextAddQuadCurveToPoint(context, 110, 30, 130, 60);
        CGContextStrokePath(context);
        
        // 折线
        NSArray *points = @[
                            [NSValue valueWithCGPoint:CGPointMake(150, 30)],
                            [NSValue valueWithCGPoint:CGPointMake(170, 60)],
                            [NSValue valueWithCGPoint:CGPointMake(190, 30)],
                            ];
        UIBezierPath *path = [UIBezierPath.fw linesWithPoints:points];
        CGContextAddPath(context, path.CGPath);
        CGContextStrokePath(context);
        
        // 贝塞尔曲线
        points = @[
                   [NSValue valueWithCGPoint:CGPointMake(210, 30)],
                   [NSValue valueWithCGPoint:CGPointMake(230, 60)],
                   [NSValue valueWithCGPoint:CGPointMake(250, 30)],
                   ];
        path = [UIBezierPath.fw quadCurvedPathWithPoints:points];
        CGContextAddPath(context, path.CGPath);
        CGContextStrokePath(context);
        
    }
    
    // 画文字
    {
        NSString *string = @"我是文字";
        [string drawAtPoint:CGPointMake(20, 80) withAttributes:@{
                                                                 NSFontAttributeName: [UIFont boldSystemFontOfSize:16],
                                                                 NSForegroundColorAttributeName: [[UIColor blackColor] colorWithAlphaComponent:0.75],
                                                                 }];
    }
    
    // 画图片
    {
        UIImage *image = FWIcon.closeImage;
        [image drawInRect:CGRectMake(20, 120, 50, 50)];
        
        [[image fw_imageWithTintColor:[UIColor orangeColor] blendMode:kCGBlendModeNormal] drawInRect:CGRectMake(90, 120, 50, 50)];
        
        [[image fw_imageWithTintColor:[UIColor orangeColor] blendMode:kCGBlendModeDestinationIn] drawInRect:CGRectMake(160, 120, 50, 50)];
        
        [[image fw_imageWithTintColor:[UIColor orangeColor] blendMode:kCGBlendModeMultiply] drawInRect:CGRectMake(230, 120, 50, 50)];
    }
    
    // 颜色渐变
    {
        [self.fw drawLinearGradient:CGRectMake(20, 190, 50, 50) colors:@[(id)[UIColor redColor].CGColor, (id)[UIColor blueColor].CGColor] locations:NULL direction:UISwipeGestureRecognizerDirectionDown];
        [self.fw drawLinearGradient:CGRectMake(90, 190, 50, 50) colors:@[(id)[UIColor redColor].CGColor, (id)[UIColor blueColor].CGColor] locations:NULL direction:UISwipeGestureRecognizerDirectionRight];
    
        UIColor *gradientColor = [UIColor.fw gradientColorWithSize:CGSizeMake(1, 50) colors:@[(id)[UIColor blueColor].CGColor, (id)[UIColor redColor].CGColor] locations:NULL direction:UISwipeGestureRecognizerDirectionDown];
        UIView *gradientView = [[UIView alloc] initWithFrame:CGRectMake(160, 190, 50, 50)];
        gradientView.backgroundColor = gradientColor;
        [self addSubview:gradientView];
    
        gradientColor = [UIColor.fw gradientColorWithSize:CGSizeMake(1, 50) colors:@[(id)[UIColor redColor].CGColor, (id)[UIColor blueColor].CGColor] locations:NULL direction:UISwipeGestureRecognizerDirectionDown];
        UIImage *gradientImage = [UIImage fw_imageWithColor:gradientColor size:CGSizeMake(50, 50)];
        [gradientImage drawInRect:CGRectMake(230, 190, 50, 50)];
    }
    
    // 形状
    {
        UIBezierPath *path = [UIBezierPath.fw shapeHeart:CGRectMake(0, 0, 50, 50)];
        [path applyTransform:CGAffineTransformTranslate(CGAffineTransformIdentity, 20, 260)];
        CGContextAddPath(context, path.CGPath);
        CGContextSetLineWidth(context, 2);
        [[UIColor orangeColor] setStroke];
        CGContextStrokePath(context);
        UIColor *fillColor = nil;
        if (fillColor) {
            [fillColor setFill];
            CGContextAddPath(context, path.CGPath);
            CGContextFillPath(context);
        }
        
        path = [UIBezierPath.fw shapeStar:CGRectMake(0, 0, 50, 50)];
        UIImage *image = [path.fw shapeImage:CGSizeMake(50, 50) strokeWidth:2.0 strokeColor:[UIColor greenColor] fillColor:[UIColor orangeColor]];
        [image drawInRect:CGRectMake(90, 260, 50, 50)];
        
        path = [UIBezierPath.fw shapeStars:5 frame:CGRectMake(0, 0, 120, 20) spacing:5];
        [path applyTransform:CGAffineTransformTranslate(CGAffineTransformIdentity, 160, 260)];
        [self.fw drawBezierPath:path strokeWidth:2.0 strokeColor:[UIColor orangeColor] fillColor:nil];
    
        path = [UIBezierPath.fw shapeStars:3 frame:CGRectMake(160, 290, 70, 20) spacing:5];
        [self.fw drawBezierPath:path strokeWidth:2.0 strokeColor:[UIColor orangeColor] fillColor:[UIColor orangeColor]];
        path = [UIBezierPath.fw shapeStars:2 frame:CGRectMake(235, 290, 45, 20) spacing:5];
        [self.fw drawBezierPath:path strokeWidth:2.0 strokeColor:[UIColor orangeColor] fillColor:nil];
    }
    
    // Shape
    {
        UIBezierPath *path = [UIBezierPath.fw shapePlus:CGRectMake(20, 470, 30, 30)];
        [self.fw drawBezierPath:path strokeWidth:2.0 strokeColor:[UIColor orangeColor] fillColor:nil];
    
        path = [UIBezierPath.fw shapePlus:CGRectMake(70, 475, 30, 20)];
        [self.fw drawBezierPath:path strokeWidth:2.0 strokeColor:[UIColor orangeColor] fillColor:nil];
    
        path = [UIBezierPath.fw shapeMinus:CGRectMake(120, 470, 30, 30)];
        [self.fw drawBezierPath:path strokeWidth:2.0 strokeColor:[UIColor orangeColor] fillColor:nil];
    
        path = [UIBezierPath.fw shapeMinus:CGRectMake(170, 475, 30, 20)];
        [self.fw drawBezierPath:path strokeWidth:2.0 strokeColor:[UIColor orangeColor] fillColor:nil];
    
        path = [UIBezierPath.fw shapeCross:CGRectMake(220, 470, 30, 30)];
        [self.fw drawBezierPath:path strokeWidth:2.0 strokeColor:[UIColor orangeColor] fillColor:nil];
    
        path = [UIBezierPath.fw shapeCross:CGRectMake(270, 475, 30, 20)];
        [self.fw drawBezierPath:path strokeWidth:2.0 strokeColor:[UIColor orangeColor] fillColor:nil];
    
        path = [UIBezierPath.fw shapeCheck:CGRectMake(20, 520, 30, 30)];
        [self.fw drawBezierPath:path strokeWidth:2.0 strokeColor:[UIColor orangeColor] fillColor:nil];
    
        path = [UIBezierPath.fw shapeCheck:CGRectMake(70, 525, 30, 20)];
        [self.fw drawBezierPath:path strokeWidth:2.0 strokeColor:[UIColor orangeColor] fillColor:nil];
    
        path = [UIBezierPath.fw shapeFold:CGRectMake(120, 520, 30, 30) direction:UISwipeGestureRecognizerDirectionLeft];
        [self.fw drawBezierPath:path strokeWidth:2.0 strokeColor:[UIColor orangeColor] fillColor:nil];
    
        path = [UIBezierPath.fw shapeFold:CGRectMake(170, 525, 30, 20) direction:UISwipeGestureRecognizerDirectionRight];
        [self.fw drawBezierPath:path strokeWidth:2.0 strokeColor:[UIColor orangeColor] fillColor:nil];
    
        path = [UIBezierPath.fw shapeFold:CGRectMake(220, 520, 30, 30) direction:UISwipeGestureRecognizerDirectionUp];
        [self.fw drawBezierPath:path strokeWidth:2.0 strokeColor:[UIColor orangeColor] fillColor:nil];
    
        path = [UIBezierPath.fw shapeFold:CGRectMake(270, 525, 30, 20) direction:UISwipeGestureRecognizerDirectionDown];
        [self.fw drawBezierPath:path strokeWidth:2.0 strokeColor:[UIColor orangeColor] fillColor:nil];
    
        path = [UIBezierPath.fw shapeArrow:CGRectMake(20, 570, 30, 30) direction:UISwipeGestureRecognizerDirectionLeft];
        [self.fw drawBezierPath:path strokeWidth:2.0 strokeColor:[UIColor orangeColor] fillColor:nil];
    
        path = [UIBezierPath.fw shapeArrow:CGRectMake(70, 575, 30, 20) direction:UISwipeGestureRecognizerDirectionRight];
        [self.fw drawBezierPath:path strokeWidth:2.0 strokeColor:[UIColor orangeColor] fillColor:nil];
    
        path = [UIBezierPath.fw shapeArrow:CGRectMake(120, 570, 30, 30) direction:UISwipeGestureRecognizerDirectionUp];
        [self.fw drawBezierPath:path strokeWidth:2.0 strokeColor:[UIColor orangeColor] fillColor:nil];
    
        path = [UIBezierPath.fw shapeArrow:CGRectMake(170, 575, 30, 20) direction:UISwipeGestureRecognizerDirectionDown];
        [self.fw drawBezierPath:path strokeWidth:2.0 strokeColor:[UIColor orangeColor] fillColor:nil];
    
        path = [UIBezierPath.fw shapeTriangle:CGRectMake(220, 570, 30, 30) direction:UISwipeGestureRecognizerDirectionLeft];
        [self.fw drawBezierPath:path strokeWidth:2.0 strokeColor:[UIColor orangeColor] fillColor:nil];
    
        path = [UIBezierPath.fw shapeTriangle:CGRectMake(270, 575, 30, 20) direction:UISwipeGestureRecognizerDirectionRight];
        [self.fw drawBezierPath:path strokeWidth:2.0 strokeColor:[UIColor orangeColor] fillColor:nil];
    
        path = [UIBezierPath.fw shapeTriangle:CGRectMake(20, 620, 30, 30) direction:UISwipeGestureRecognizerDirectionUp];
        [self.fw drawBezierPath:path strokeWidth:2.0 strokeColor:[UIColor orangeColor] fillColor:nil];
    
        path = [UIBezierPath.fw shapeTriangle:CGRectMake(70, 625, 30, 20) direction:UISwipeGestureRecognizerDirectionDown];
        [self.fw drawBezierPath:path strokeWidth:2.0 strokeColor:[UIColor orangeColor] fillColor:nil];
    }
}

@end

@interface TestLayerViewController ()

FWPropertyWeak(UIButton *, snapshotButton);

@end

@implementation TestLayerViewController

- (void)renderView
{
    TestLayerView *layerView = [[TestLayerView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:layerView];
    
    UIButton *button = [Theme largeButton];
    self.snapshotButton = button;
    [button setTitle:@"截屏" forState:UIControlStateNormal];
    // TouchDown事件，按钮还未highlighted
    [button addTarget:self action:@selector(onSnapshot) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button];
    [button fw_pinEdgeToSuperview:NSLayoutAttributeBottom withInset:15];
    [button fw_alignAxisToSuperview:NSLayoutAttributeCenterX];
}

#pragma mark - Action

- (void)onSnapshot
{
    UIImage *image = [UIWindow.fw_mainWindow.fw snapshotImage];
    [image.fw saveImageWithCompletion:^(NSError *error){
        NSLog(@"%@", error == nil ? @"保存成功" : @"保存失败");
    }];
}

@end
