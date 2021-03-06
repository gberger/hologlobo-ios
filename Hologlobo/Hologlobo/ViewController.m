//
//  ViewController.m
//  Hologlobo
//
//  Created by Fabio Dela Antonio on 9/5/15.
//  Copyright (c) 2015 hologlobo. All rights reserved.
//

#import "ViewController.h"
#import "ProjectionView.h"

//#import "fopen+Bundle.h"

@interface ViewController () {
    unsigned _i;
}

@property (retain, nonatomic) IBOutlet UIView * motherView;

@property (retain, nonatomic) IBOutlet ProjectionView * projectionView;
@property (retain, nonatomic) IBOutlet ProjectionView * rightView;
@property (retain, nonatomic) IBOutlet ProjectionView * bottomView;
@property (retain, nonatomic) IBOutlet ProjectionView * leftView;

@property (retain, nonatomic) CADisplayLink * displayLink;

@property (nonatomic, retain) NSString * file;

@property (retain, nonatomic) IBOutlet UISlider * rotationSlider;
@property (retain, nonatomic) IBOutlet UISlider * distanceSlider;

@property (retain, nonatomic) IBOutlet UIView * referenceView;
@property (retain, nonatomic) IBOutlet UIView * contractedReferenceView;
@property (retain, nonatomic) IBOutlet UIView * expandView;

@property (nonatomic, assign, getter=isExpanded) BOOL expanded;
@property (retain, nonatomic) IBOutlet UIButton * expandButton;

@end

@implementation ViewController

+ (instancetype)viewControllerWithFile:(NSString *)file {
    
    ViewController * vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ViewController"];
    [vc setFile:file];
    return vc;
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewDidLoad {
    
//#warning MOCK
//    setDocumentsDirectory(@"55ec7ba5c3be523b001fda8e");
//    self.file = @"model.obj";
//#warning FIM DO MOCK
    
    [super viewDidLoad];
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    CGFloat size = (frame.size.width < frame.size.height ? frame.size.width:frame.size.height) - 20.f;
    
    [self.motherView setFrame:CGRectMake(10.f, self.view.frame.size.height/2.f - size/2.f, size, size)];
    
    CGFloat viewSize = size/2.f - 50.f;
    
    [self.projectionView setFrame:CGRectMake(size/2.f - viewSize/2.f, 0, viewSize, viewSize)];
    [self.rightView setFrame:CGRectMake(size/2.f + 50.f, size/2.f - viewSize/2.f, viewSize, viewSize)];
    [self.bottomView setFrame:CGRectMake(size/2.f - viewSize/2.f, size/2.f + 50.f, viewSize, viewSize)];
    [self.leftView setFrame:CGRectMake(0, size/2.f - viewSize/2.f, viewSize, viewSize)];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [_projectionView release], _projectionView = nil;
    [_rightView release], _rightView = nil;
    [_bottomView release], _bottomView = nil;
    [_leftView release], _leftView = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if(!_displayLink) {
        
        _displayLink = [[CADisplayLink displayLinkWithTarget:self selector:@selector(gameLoop:)] retain];
        _displayLink.frameInterval = 1; /* ~ 60 fps */
        
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    
    [self prepareForRendering];
}

- (IBAction)rotationChanged:(id)sender {

    [self.projectionView setControlRotation:YES];
    [self.rightView setControlRotation:YES];
    [self.bottomView setControlRotation:YES];
    [self.leftView setControlRotation:YES];
}

- (void)prepareForRendering {
    
    [self.projectionView prepareForRenderingWithFile:self.file rotation:0.f];
    [self.leftView prepareForRenderingWithFile:self.file rotation:90.f];
    [self.bottomView prepareForRenderingWithFile:self.file rotation:180.f];
    [self.rightView prepareForRenderingWithFile:self.file rotation:270.f];
}

- (void)gameLoop:(CADisplayLink *)link {
    
    double timeDiff = link.duration;
    
    if(_i == 0) {
    
        [self.projectionView setRotation:self.rotationSlider.value];
        [self.projectionView setDistance:self.distanceSlider.value];
        [self.projectionView renderFrameWithInterval:timeDiff * 4.f];
    }
        
    else if(_i == 1) {
        
        
        [self.rightView setRotation:self.rotationSlider.value];
        [self.rightView setDistance:self.distanceSlider.value];
        [self.rightView renderFrameWithInterval:timeDiff * 4.f];
    }
    
    else if(_i == 2) {
        
        [self.bottomView setRotation:self.rotationSlider.value];
        [self.bottomView setDistance:self.distanceSlider.value];
        [self.bottomView renderFrameWithInterval:timeDiff * 4.f];
    }
    
    else if(_i == 3) {
        
        [self.leftView setRotation:self.rotationSlider.value];
        [self.leftView setDistance:self.distanceSlider.value];
        [self.leftView renderFrameWithInterval:timeDiff * 4.f];
    }
    
    _i = (_i + 1) % 4;
}

- (IBAction)expandAction:(id)sender {

    if(_expanded) {
     
        [UIView animateWithDuration:0.2 animations:^{
            self.expandView.frame = self.contractedReferenceView.frame;
        } completion:^(BOOL finished) {
            _expanded = NO;
            [self.expandButton setTitle:@"+" forState:UIControlStateNormal];
        }];
    }
    
    else {
        
        [UIView animateWithDuration:0.2 animations:^{
            self.expandView.frame = self.referenceView.frame;
        } completion:^(BOOL finished) {
            _expanded = YES;
            [self.expandButton setTitle:@"-" forState:UIControlStateNormal];
        }];
    }
}

- (IBAction)backAction:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    
    [_displayLink setPaused:YES];
    [_displayLink invalidate];
    [_displayLink release], _displayLink = nil;
    
    [_projectionView release], _projectionView = nil;
    [_rightView release], _rightView = nil;
    [_bottomView release], _bottomView = nil;
    [_leftView release], _leftView = nil;
    
    [_file release], _file = nil;
    [_rotationSlider release];
    [_distanceSlider release];
    [_referenceView release];
    [_expandView release];
    [_contractedReferenceView release];
    [_motherView release];
    [_expandButton release];
    [super dealloc];
}

@end
