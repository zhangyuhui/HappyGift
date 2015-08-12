//
//  HGImageComposeDrawingView.m
//  HappyGift
//
//  Created by Yuhui Zhang on 7/27/12.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGImageComposeDrawingView.h"
#import "QuartzCore/QuartzCore.h"

@interface HGImageComposeDrawingView()
-(void)initSubViews;
@end

@implementation HGImageComposeDrawingView
@synthesize drawingWidth;
@synthesize drawingColor;

- (void)awakeFromNib {
	[self initSubViews];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self initSubViews];
    }
    return self;
}

- (void)initSubViews{
    drawingWidth = 4.0;
    drawingColor = [[UIColor blueColor] retain];
    self.backgroundColor = [UIColor clearColor];
    [self updateDrawingBuffer];
}

- (void)dealloc{
    [drawingColor release];
    free(drawingBufferData);
    [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch =  [touches anyObject];
    CGPoint point = [touch locationInView:self];
    drawingPoints = [[NSMutableArray alloc] init];
    [drawingPoints addObject:[NSValue valueWithCGPoint:point]];
    [self updateDrawingBuffer];
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch =  [touches anyObject];
    CGPoint point = [touch locationInView:self];
    [drawingPoints addObject:[NSValue valueWithCGPoint:point]];
    [self updateDrawingBuffer];
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (drawingPoints != nil && [drawingPoints count] > 0){
        [drawingPoints release];
        drawingPoints = nil;
    }
    if (drawingPoints != nil){
        [drawingPoints release];
        drawingPoints = nil;
    }
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    if (drawingPoints != nil && [drawingPoints count] > 0){
        [drawingPoints release];
        drawingPoints = nil;
    }
    if (drawingPoints != nil){
        [drawingPoints release];
        drawingPoints = nil;
    }
    [self setNeedsDisplay];
}

- (void)createDrawingBuffer{
    if (drawingBufferContext == NULL){
        int drawingBufferWidth = self.frame.size.width;
        int drawingBufferHeight = self.frame.size.height;
        
        int drawingBufferBytesPerRow = (drawingBufferWidth * 4);
        int drawingBufferByteCount = (drawingBufferBytesPerRow * drawingBufferHeight);
        
        CGColorSpaceRef drawingBufferColorSpace = CGColorSpaceCreateDeviceRGB();
        drawingBufferData = malloc( drawingBufferByteCount );
        if (drawingBufferData == NULL) {
            return;
        }
        drawingBufferContext = CGBitmapContextCreate (drawingBufferData,
                                                      drawingBufferWidth,
                                                      drawingBufferHeight,
                                                      8,     
                                                      drawingBufferBytesPerRow,
                                                      drawingBufferColorSpace,
                                                      kCGImageAlphaPremultipliedLast);
        if (drawingBufferContext== NULL){
            free (drawingBufferData);
            return;
        }
        
        CGColorRef fillColor = [[UIColor clearColor] CGColor];
        CGContextSetFillColor(drawingBufferContext, CGColorGetComponents(fillColor));
        CGContextFillRect(drawingBufferContext, CGRectMake (0, 0, drawingBufferWidth, drawingBufferHeight));
        
        CGColorSpaceRelease( drawingBufferColorSpace );  
    }
}

- (void)updateDrawingBuffer{
    if (drawingBufferContext == NULL){
        int drawingBufferWidth = self.frame.size.width;
        int drawingBufferHeight = self.frame.size.height;
        
        int drawingBufferBytesPerRow = (drawingBufferWidth * 4);
        int drawingBufferByteCount = (drawingBufferBytesPerRow * drawingBufferHeight);
        
        CGColorSpaceRef drawingBufferColorSpace = CGColorSpaceCreateDeviceRGB();
        drawingBufferData = malloc( drawingBufferByteCount );
        if (drawingBufferData == NULL) {
            return;
        }
        drawingBufferContext = CGBitmapContextCreate (drawingBufferData,
                                                      drawingBufferWidth,
                                                      drawingBufferHeight,
                                                      8,     
                                                      drawingBufferBytesPerRow,
                                                      drawingBufferColorSpace,
                                                      kCGImageAlphaPremultipliedLast);
        if (drawingBufferContext== NULL){
            free (drawingBufferData);
            return;
        }
        
        CGColorRef fillColor = [[UIColor clearColor] CGColor];
        CGContextSetFillColor(drawingBufferContext, CGColorGetComponents(fillColor));
        CGContextFillRect(drawingBufferContext, CGRectMake (0, 0, drawingBufferWidth, drawingBufferHeight));
        CGColorSpaceRelease( drawingBufferColorSpace );  
    }
    
    if (drawingBufferContext != NULL){
        CGContextSaveGState(drawingBufferContext);
        CGContextSetShouldAntialias(drawingBufferContext, YES);
        CGContextSetAllowsAntialiasing(drawingBufferContext, YES);
        CGContextSetMiterLimit(drawingBufferContext, 2.0);
        CGContextSetLineCap(drawingBufferContext, kCGLineCapRound);
        CGContextSetLineJoin(drawingBufferContext, kCGLineJoinRound);
        CGContextSetFlatness(drawingBufferContext, 0.1f);
        
        CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, self.frame.size.height);
        CGContextConcatCTM(drawingBufferContext, flipVertical);  
        
        if (drawingPoints != nil){
            BOOL firstPoint = YES;
            CGContextSetLineWidth(drawingBufferContext, drawingWidth);
            CGContextSetStrokeColorWithColor(drawingBufferContext, drawingColor.CGColor);
            CGPoint lastPoint;
            for (NSValue* theDrawingPoint in drawingPoints){
                CGPoint thePoint = [theDrawingPoint CGPointValue];
                if (firstPoint){
                    firstPoint = NO;
                    CGContextMoveToPoint(drawingBufferContext, thePoint.x, thePoint.y);
                    CGContextAddLineToPoint(drawingBufferContext, thePoint.x, thePoint.y);
                }else{
                    CGPoint midPoint = CGPointMake((lastPoint.x + thePoint.x) * 0.5, (lastPoint.y + thePoint.y) * 0.5); 
                    CGContextAddQuadCurveToPoint(drawingBufferContext, midPoint.x, midPoint.y, thePoint.x, thePoint.y);  
                }
                
                lastPoint = thePoint;
            }
            
            CGContextStrokePath(drawingBufferContext);
        }
        
        CGContextRestoreGState(drawingBufferContext);
    }
}

- (void)drawRect:(CGRect)rect{
    UIImage* drawingBufferImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(drawingBufferContext)];
    [drawingBufferImage drawInRect:rect];
}

@end
