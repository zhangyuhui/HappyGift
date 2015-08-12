//
//  HGImageComposeItemView.m
//  HappyGift
//
//  Created by Yuhui Zhang on 7/27/12.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGImageComposeItemView.h"
#import "QuartzCore/QuartzCore.h"

@interface HGImageComposeItemView()
-(void)initSubViews;
@end

@implementation HGImageComposeItemView
@synthesize image;
@synthesize topCorner;
@synthesize bottomCorner;
@synthesize innerCenter;
@synthesize selected;

- (void)awakeFromNib {
	[self initSubViews];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self initSubViews];
    }
    return self;
}

- (void)setContentMode:(UIViewContentMode)theContentMode{
    imageView.contentMode = theContentMode;
}

- (void)initSubViews{
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];    
    [self addSubview:imageView];

    topCorner = CGPointMake(0.0, 0.0);
    bottomCorner = CGPointMake(self.frame.size.width, self.frame.size.height);
    innerCenter = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
    //topCornerTransform = CGAffineTransformIdentity;
    //bottomCornerTransform = CGAffineTransformIdentity;
    selected = NO;
    self.backgroundColor = [UIColor clearColor];
}

- (void)dealloc{
    [imageView release];
    [super dealloc];
}

- (void)setImage:(UIImage *)theImage{
    imageView.image = theImage;
}

- (UIImage*)image{
    return imageView.image;
}

- (void)setSelected:(BOOL)theSelected{
    if (selected != theSelected){
        selected = theSelected;
        [self setNeedsDisplay];
    }
}

- (void)performTranslate:(CGPoint)translation{
    CATransform3D transform3D = CATransform3DIdentity;
    transform3D = CATransform3DTranslate(transform3D, translation.x, translation.y, 0);
    transform3D = CATransform3DConcat(self.layer.transform, transform3D);
    self.layer.transform = transform3D;
}

- (void)performZoom:(CGFloat)scale{
    CATransform3D transform3D = self.layer.transform;
    transform3D = CATransform3DTranslate(transform3D, self.bounds.size.width*(scale+1.0)/2.0, self.bounds.size.height*(scale+1.0)/2.0, 0);
    transform3D = CATransform3DScale(transform3D, scale + 1.0, scale + 1.0, 1.0);
    transform3D = CATransform3DTranslate(transform3D, -self.bounds.size.width/2.0, -self.bounds.size.height/2.0, 0);
    self.layer.transform = transform3D;
    
//    CGAffineTransform transform2D = topCornerTransform;
//    transform2D = CGAffineTransformScale(transform2D, scale + 1.0, scale + 1.0);
//    topCornerTransform = transform2D;
//    topCorner = CGPointApplyAffineTransform(topCorner, topCornerTransform); 
    
//    transform2D = bottomCornerTransform;
//    transform2D = CGAffineTransformTranslate(transform2D, self.bounds.size.width, self.bounds.size.height);
//    transform2D = CGAffineTransformScale(transform2D, scale + 1.0, scale + 1.0);
//    transform2D = CGAffineTransformTranslate(transform2D, -self.bounds.size.width, -self.bounds.size.height);
//    bottomCornerTransform = transform2D;
//    bottomCorner = CGPointApplyAffineTransform(bottomCorner, bottomCornerTransform); 
    
    [self setNeedsDisplay];
}

- (void)performRotate:(CGFloat)rotation{
    CATransform3D transform = self.layer.transform;
    transform = CATransform3DRotate(transform, rotation, 0, 0, 1);
    self.layer.transform = transform;  
    
//    CGAffineTransform transform2D = topCornerTransform;
//    transform2D = CGAffineTransformRotate(transform2D, rotation);
//    topCornerTransform = transform2D;
//    topCorner = CGPointApplyAffineTransform(topCorner, topCornerTransform); 
    
//    transform2D = bottomCornerTransform;
//    transform2D = CGAffineTransformTranslate(transform2D, self.bounds.size.width, self.bounds.size.height);
//    transform2D = CGAffineTransformRotate(transform2D, rotation);
//    transform2D = CGAffineTransformTranslate(transform2D, -self.bounds.size.width, -self.bounds.size.height);
//    bottomCornerTransform = transform2D;
//    bottomCorner = CGPointApplyAffineTransform(bottomCorner, bottomCornerTransform);     
}

- (void)drawRect:(CGRect)rect{
    if (self.selected){
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        CGContextSetAllowsAntialiasing(context, YES);
        
        float finalScaleX = [[self.layer valueForKeyPath: @"transform.scale.x"] floatValue];
        float lineWidth = 1.5/finalScaleX;
        
        CGContextSetLineWidth(context, lineWidth);
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        
        CGRect selectedRect = rect;
        selectedRect.origin.x += lineWidth;
        selectedRect.origin.y += lineWidth;
        selectedRect.size.width -= lineWidth*2.0;
        selectedRect.size.height -= lineWidth*2.0;
        
        CGContextAddRect(context, selectedRect);
        CGContextClosePath(context);
        CGContextStrokePath(context);
        
        selectedRect.origin.x += lineWidth;
        selectedRect.origin.y += lineWidth;
        selectedRect.size.width -= lineWidth*2.0;
        selectedRect.size.height -= lineWidth*2.0;
        
        
        CGContextSetLineWidth(context, lineWidth);
        CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
        CGContextAddRect(context, selectedRect);
        CGContextClosePath(context);
        CGContextStrokePath(context);
        
        CGContextRestoreGState(context);
    }
}

@end
