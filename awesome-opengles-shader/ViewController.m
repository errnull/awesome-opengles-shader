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
    GLKBaseEffect *baseEffect;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupContext];
    [self setupVertexData];
    [self setupTexture];
}

- (void)setupContext {
    // 1. 初始化上下文
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!context) {
        NSLog(@"context 创建失败");
        return;
    }
    
    // 2. 设置上下文
    [EAGLContext setCurrentContext:context];
    
    // 3. 获取 GLKView
    GLKView *view = (GLKView *)self.view;
    view.context = context;
    
    // 4. 配置渲染缓冲区
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    // 5. 设置背景颜色
    glClearColor(1, 0, 0, 1);
}

- (void)setupVertexData {
    // 1. 顶点坐标，纹理坐标
    // (x, y, z), (s, t)
    GLfloat vertexData[] = {
        0.5, -0.5, 0.0,     1.0, 0.0,   // 右下
        0.5,  0.5, 0.0,     1.0, 1.0,   // 右上
       -0.5,  0.5, 0.0,     0.0, 1.0,   // 左上
        
        0.5, -0.5, 0.0,     1.0, 0.0,   // 右下
       -0.5,  0.5, 0.0,     0.0, 1.0,   // 左上
       -0.5, -0.5, 0.0,     0.0, 0.0,   // 左下
    };
    
    // 2. 开辟顶点缓冲区（显存）
    // (1). 创建顶点缓冲区 ID
    GLuint bufferID;
    glGenBuffers(1, &bufferID);
    // (2). 绑定缓冲区（声明作用）
    glBindBuffer(GL_ARRAY_BUFFER, bufferID);
    // (3). 将顶点数据从内容copy到顶点缓冲区(内存->显存)
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW);
    
    // (4). 打开顶点属性(attribute)，默认关闭
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    //    GLKVertexAttribPosition, 顶点
    //    GLKVertexAttribNormal,   法线
    //    GLKVertexAttribColor,    颜色值
    //    GLKVertexAttribTexCoord0,纹理0
    //    GLKVertexAttribTexCoord1 纹理1
    
    // (5). 指定 OpenGL 顶点数据读取方式
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GL_FLOAT) * 5, (GLfloat *)NULL + 0);

    // 纹理
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GL_FLOAT) * 5, (GLfloat *)NULL + 3);
}

- (void)setupTexture {
    // 1. 获取纹理图片路径
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"stretch" ofType:@"jpg"];
    // 2. 设置纹理相关参数
    // 解决纹理翻转 纹理原点：左下角，view 原点：左上角
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    // 3. GLBaseEffect 完成着色器工作
    baseEffect = [[GLKBaseEffect alloc] init];
    baseEffect.texture2d0.enabled = GL_TRUE;
    baseEffect.texture2d0.name = textureInfo.name;
}

#pragma mark - GLKView Delegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    // 1.
    glClear(GL_COLOR_BUFFER_BIT);
    // 2.
    [baseEffect prepareToDraw];
    // 3. 开始绘制
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

@end
