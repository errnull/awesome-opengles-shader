//
//  ViewController.m
//  awesome-opengles-shader
//
//  Created by errnull on 2023/4/24.
//

#import "ViewController.h"

#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

@interface ViewController ()
{
    EAGLContext *context; // 上下文，管理 OpenGL ES 状态的
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1. 初始化上下文
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!context) {
        NSLog(@"context 创建失败");
    }
    
    // 2. 设置上下文
    [EAGLContext setCurrentContext:context];
    
    // 3. 获取 GLKView
    GLKView *view = (GLKView *)self.view;
    view.context = context;
    
    // 4. 设置背景颜色
    glClearColor(1, 0, 0, 1);
}

#pragma mark - GLKView Delegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClear(GL_COLOR_BUFFER_BIT);
}

@end
