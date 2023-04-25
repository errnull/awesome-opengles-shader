//
//  ViewController.m
//  awesome-opengles-shader
//
//  Created by errnull on 2023/4/24.
//

//#import <GLKit/GLKit.h>
#import "ViewController.h"
#import "VCView.h"

@interface ViewController ()

@property (nonatomic, strong) VCView *vcView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.vcView = (VCView *)self.view;
}

@end
