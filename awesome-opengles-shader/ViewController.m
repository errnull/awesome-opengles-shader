//
//  ViewController.m
//  awesome-opengles-shader
//
//  Created by errnull on 2023/4/24.
//

#import <GLKit/GLKit.h>
#import "ViewController.h"

typedef struct {
    GLKVector3 positionCoord;
    GLKVector2 textureCoord;
} VCVertex;

// 顶点数
static NSInteger const kCoordCount = 36;

@interface ViewController () <GLKViewDelegate>

@property (nonatomic, strong) GLKView *glkView;
@property (nonatomic, strong) GLKBaseEffect *baseEffect;

@property (nonatomic, assign) VCVertex *vertices;
@property (nonatomic, assign) GLuint vertexBuffer;

@end

@implementation ViewController

- (void)dealloc {
    if ([EAGLContext currentContext] == self.glkView.context) {
        [EAGLContext setCurrentContext:nil];
    }
    if (_vertices) {
        free(_vertices);
        _vertices = nil;
    }
    
    if (_vertexBuffer) {
        glDeleteBuffers(1, &_vertexBuffer);
        _vertexBuffer = 0;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    
    [self setupContext];
    [self setupTexture];
    [self setupVertexData];
}

- (void)setupContext {
    // 1. 初始化上下文
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:context];

    // 2. 创建 GLKView 并设置代理
    CGRect frame = self.view.bounds;
    self.glkView = [[GLKView alloc] initWithFrame:frame context:context];
    self.glkView.backgroundColor = [UIColor clearColor];
    self.glkView.delegate = self;

    // 4. 配置渲染缓冲区
    self.glkView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    self.glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;

    // 5. 将 GLKView 添加self.view 上
    [self.view addSubview:self.glkView];
}

- (void)setupTexture {
    // 1. 获取纹理图片路径
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"stretch" ofType:@"jpg"];
    // 2. 设置纹理相关参数
    // 解决纹理翻转 纹理原点：左下角，view 原点：左上角
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];

    // 3. GLBaseEffect 完成着色器工作
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.texture2d0.name = textureInfo.name;
    self.baseEffect.texture2d0.target = textureInfo.target;
}


- (void)setupVertexData {
    // 1. 顶点坐标，纹理坐标
    // (x, y, z), (s, t)
    self.vertices = malloc(sizeof(VCVertex) * kCoordCount);

    self.vertices[0] = (VCVertex){{ 0.5, -0.5, 0.0}, {1.0, 0.0}}; // 右下
    self.vertices[1] = (VCVertex){{ 0.5,  0.5, 0.0}, {1.0, 1.0}}; // 右上
    self.vertices[2] = (VCVertex){{-0.5,  0.5, 0.0}, {0.0, 1.0}}; // 左上
    
    self.vertices[3] = (VCVertex){{ 0.5, -0.5, 0.0}, {1.0, 0.0}}; // 右下
    self.vertices[4] = (VCVertex){{-0.5,  0.5, 0.0}, {0.0, 1.0}}; // 左上
    self.vertices[5] = (VCVertex){{-0.5, -0.5, 0.0}, {0.0, 0.0}}; // 左下
    
    // 2. 开辟顶点缓冲区（显存）
    // (1). 创建顶点缓冲区 ID
    glGenBuffers(1, &_vertexBuffer);
    // (2). 绑定缓冲区（声明作用）
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    // (3). 将顶点数据从内容copy到顶点缓冲区(内存->显存)
    GLsizeiptr bufferSizeBytes = sizeof(VCVertex) * kCoordCount;
    glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, self.vertices, GL_STATIC_DRAW);

    // (4). 打开顶点属性(attribute)，默认关闭
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    //    GLKVertexAttribPosition, 顶点
    //    GLKVertexAttribNormal,   法线
    //    GLKVertexAttribColor,    颜色值
    //    GLKVertexAttribTexCoord0,纹理0
    //    GLKVertexAttribTexCoord1 纹理1

    // (5). 指定 OpenGL 顶点数据读取方式
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(VCVertex), NULL + offsetof(VCVertex, positionCoord));
    
    //纹理数据
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(VCVertex), NULL + offsetof(VCVertex, textureCoord));
}

#pragma mark - GLKView Delegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    //1. 开启深度测试
    glEnable(GL_DEPTH_TEST);
    //2. 清除颜色缓存区&深度缓存区
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    //3. 准备绘制
    [self.baseEffect prepareToDraw];
    
    //4. 绘图
    glDrawArrays(GL_TRIANGLES, 0, kCoordCount);
}


@end
