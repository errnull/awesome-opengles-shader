//
//  VCView.m
//  awesome-opengles-shader
//
//  Created by errnull on 2023/4/25.
//

#import <GLKit/GLKit.h>
#import "VCView.h"

typedef struct {
    GLKVector3 positionCoord;
    GLKVector2 textureCoord;
} VCVertex;

// 顶点数
static NSInteger const kCoordCount = 36;

@interface VCView()

@property (nonatomic, strong) CAEAGLLayer *vcEAGLLayer;
@property (nonatomic, strong) EAGLContext *vcContext;

@property (nonatomic, assign) GLuint vcColorFrameBuffer;
@property (nonatomic, assign) GLuint vcColorRenderBuffer;

@property (nonatomic, assign) GLuint vcProgram;

@property (nonatomic, assign) VCVertex *vertices;
@property (nonatomic, assign) GLuint vertexBuffer;

@end

@implementation VCView

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self setupSubviews];
    }
    return self;
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)setupSubviews {
    [self setupLayer];
    [self setupContext];
    [self deleteFrameAndRenderBuffer];
    
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    
    [self renderLayer];
    [self setupVertexData];
    [self setupTexture:@"stretch"];
    [self prepareToRender];
}

- (void)setupLayer {
    // 1. 创建特殊图层(EAGLLayer)
    self.vcEAGLLayer = (CAEAGLLayer *)self.layer;
    
    // 2. 设置 scale
    [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
    
    // 3. 描述属性
    self.vcEAGLLayer.drawableProperties =
    @{
        kEAGLDrawablePropertyRetainedBacking : @(false),
        kEAGLDrawablePropertyColorFormat     : kEAGLColorFormatRGBA8
    };
}

- (void)setupContext {
    // 1.
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES3;
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:api];
    if (!context) {
        NSLog(@"failed create context");
        return;
    }
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"failed setCurrent context");
        return;
    }
    self.vcContext = context;
}

- (void)deleteFrameAndRenderBuffer {
    // 在使用之前清空 FrameBuffer、RenderBufer
    glDeleteBuffers(1, &_vcColorFrameBuffer);
    self.vcColorFrameBuffer = 0;
    
    glDeleteBuffers(1, &_vcColorRenderBuffer);
    self.vcColorRenderBuffer = 0;
}

- (void)setupFrameBuffer {
    // 1. 定义缓冲区 ID
    GLuint buffer;
    
    // 2. 申请对应的标识符
    glGenFramebuffers(1, &buffer);
    
    // 3. 绑定标识符与缓冲区
    glBindFramebuffer(GL_FRAMEBUFFER, buffer);
    
    // 4. 生成帧缓存区，将渲染缓存和帧缓存绑定到一起
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.vcColorRenderBuffer);
    
    self.vcColorFrameBuffer = buffer;
}

- (void)setupRenderBuffer {
    // 1. 定义缓冲区 ID
    GLuint buffer;
    
    // 2. 申请对应的标识符
    glGenRenderbuffers(1, &buffer);
    
    // 3. 绑定标识符与缓冲区
    glBindRenderbuffer(GL_RENDERBUFFER, buffer);
    
    // 4. 将可绘制对象 CAEAGLLayer 绑定 ColorRenderBuffer
    [self.vcContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.vcEAGLLayer];
    
    self.vcColorRenderBuffer = buffer;
}

- (void)renderLayer {
    // 1.
    glClearColor(0.2, 0.1, 0.3, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 2.
    CGFloat scale = [[UIScreen mainScreen] scale];
    glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale, self.frame.size.width * scale, self.frame.size.height * scale);
    
    // 3. 读取顶点/片元着色器
    NSString *vertFilePath = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@".vsh"];
    NSString *fragFilePath = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@".fsh"];
    
    // 4. 加载 Shader
    self.vcProgram = [self loadShaders:vertFilePath andFrag:fragFilePath];
    
    // 5. 链接 program
    glLinkProgram(self.vcProgram);
    GLint linkStatus;
    glGetProgramiv(self.vcProgram, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        GLchar message[1024];
        glGetProgramInfoLog(self.vcProgram, sizeof(message), 0, &message);
        NSLog(@"Program link failed: %@", [NSString stringWithUTF8String:message]);
        return;
    }
    NSLog(@"Program link success！");
    
    // 6. 使用 Program
    glUseProgram(self.vcProgram);
}

- (void)setupVertexData {
    // 1. 顶点坐标，纹理坐标
    // (x, y, z), (s, t)
    self.vertices = malloc(sizeof(VCVertex) * kCoordCount);
    
//    GLfloat attrArr[] =
//    {
//        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
//        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
//        -0.5f, -0.5f, -1.0f,    0.0f, 0.0f,
//
//        0.5f, 0.5f, -1.0f,      1.0f, 1.0f,
//        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
//        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
//    };

    self.vertices[0] = (VCVertex){{ 0.5, -0.5, -1.0}, {1.0, 0.0}}; // 右下
    self.vertices[1] = (VCVertex){{-0.5,  0.5, -1.0}, {0.0, 1.0}}; // 右上
    self.vertices[2] = (VCVertex){{-0.5, -0.5, -1.0}, {0.0, 0.0}}; // 左上

    self.vertices[3] = (VCVertex){{ 0.5,  0.5, -1.0}, {1.0, 1.0}}; // 右下
    self.vertices[4] = (VCVertex){{-0.5,  0.5, -1.0}, {0.0, 1.0}}; // 左上
    self.vertices[5] = (VCVertex){{ 0.5, -0.5, -1.0}, {1.0, 0.0}}; // 左下
    
    // 2. 开辟顶点缓冲区（显存）
    // (1). 创建顶点缓冲区 ID
    glGenBuffers(1, &_vertexBuffer);
    // (2). 绑定缓冲区（声明作用）
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    // (3). 将顶点数据从内容copy到顶点缓冲区(内存->显存)
    GLsizeiptr bufferSizeBytes = sizeof(VCVertex) * kCoordCount;
    glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, self.vertices, GL_STATIC_DRAW);

    // (4). 打开顶点属性(attribute)，默认关闭
    GLuint position = glGetAttribLocation(self.vcProgram, "a_position");
    glEnableVertexAttribArray(position);
    // (5). 指定 OpenGL 顶点数据读取方式
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(VCVertex), NULL + offsetof(VCVertex, positionCoord));
    
    //纹理数据
    GLuint texture = glGetAttribLocation(self.vcProgram, "a_textureCoord");
    glEnableVertexAttribArray(texture);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(VCVertex), NULL + offsetof(VCVertex, textureCoord));
}

//从图片中加载纹理
- (GLuint)setupTexture:(NSString *)fileName {
    // 1. 获取图片数据
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"stretch" ofType:@".jpg"];
    CGImageRef spriteImage = [UIImage imageWithContentsOfFile:imagePath].CGImage;
    
    // 2.
    if (!spriteImage) {
        NSLog(@"Failed to load image.");
        return 0;
    }
    
    // 3. 图片本身宽/高等信息
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    // 图片大小
    GLubyte *spriteData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
    
    // 4. 创建上下文
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    // 5. 将图片绘制出来
    CGRect rect = CGRectMake(0, 0, width, height);
    CGContextDrawImage(spriteContext, rect, spriteImage);
    
    // 6.
    CGContextRelease(spriteContext);
    
    // 7. 绑定纹理
    glBindTexture(GL_TEXTURE_2D, 0);
    
    // 8. 设置纹理属性
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    // 9. 加载 2D 纹理数据
    float fw = width;
    float fh = height;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    // 10. 释放内存
    free(spriteData);

    return 0;
}

- (void)prepareToRender {
    // 1. 设置纹理采样器
    glUniform1i(glGetUniformLocation(self.vcProgram, "u_colorMap"), 0);
    
    // 2. 绘图
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    // 3.
    [self.vcContext presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark --shader

-(GLuint)loadShaders:(NSString *)vert andFrag:(NSString *)frag {
    // 1. 定义两个临时着色器对象
    GLuint vertShader, fragShader;
    GLuint program = glCreateProgram();
    
    // 2. 编译顶点/片元着色器
    [self compileShader:&vertShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];
    
    // 3.
    glAttachShader(program, vertShader);
    glAttachShader(program, fragShader);
    
    // 4.
    glDeleteShader(vertShader);
    glDeleteShader(fragShader);
    
    return program;
}

- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
    // 1. 读取文件路径字符串
    NSString* content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar* source = (GLchar *)[content UTF8String];
    
    // 2. 创建一个shader（根据type类型）
    *shader = glCreateShader(type);
    
    // 3. 将着色器源码附加到着色器对象上。
    glShaderSource(*shader, 1, &source,NULL);
    
    // 4. 把着色器源代码编译成目标代码
    glCompileShader(*shader);
}


@end
