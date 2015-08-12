//
//  UIImage+Addition.m
//  HappyGift
//
//  Created by Zhang Yuhui on 12/14/10.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "UIImage+Addition.h"
#import "HGDefines.h"

@implementation UIImage (Additions)

- (UIImage *)imageWithScale:(CGSize)size {
	if (size.width != self.size.width || size.height != self.size.height){
		CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
		UIGraphicsBeginImageContext(rect.size);
		[self drawInRect:rect];
		UIImage *resImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		return resImage;
	}else {
		return self;
	}
}

- (UIImage *)imageWithReflection:(CGFloat)fraction {
	int reflectionHeight = self.size.height * fraction;
	
    // create a 2 bit CGImage containing a gradient that will be used for masking the
    // main view content to create the 'fade' of the reflection. The CGImageCreateWithMask
    // function will stretch the bitmap image as required, so we can create a 1 pixel wide gradient
	CGImageRef gradientMaskImage = NULL;
	
    // gradient is always black-white and the mask must be in the gray colorspace
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // create the bitmap context
    CGContextRef gradientBitmapContext = CGBitmapContextCreate(nil, 1, reflectionHeight,
                                                               8, 0, colorSpace, kCGImageAlphaNone);
    
    // define the start and end grayscale values (with the alpha, even though
    // our bitmap context doesn't support alpha the gradient requires it)
    CGFloat colors[] = {0.0, 1.0, 1.0, 1.0};
    
    // create the CGGradient and then release the gray color space
    CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
    CGColorSpaceRelease(colorSpace);
    
    // create the start and end points for the gradient vector (straight down)
    CGPoint gradientStartPoint = CGPointMake(0, reflectionHeight);
    CGPoint gradientEndPoint = CGPointZero;
    
    // draw the gradient into the gray bitmap context
    CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint,
                                gradientEndPoint, kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(grayScaleGradient);
	
	// add a black fill with 50% opacity
	CGContextSetGrayFillColor(gradientBitmapContext, 0.0, 0.5);
	CGContextFillRect(gradientBitmapContext, CGRectMake(0, 0, 1, reflectionHeight));
    
    // convert the context into a CGImageRef and release the context
    gradientMaskImage = CGBitmapContextCreateImage(gradientBitmapContext);
    CGContextRelease(gradientBitmapContext);
	
    // create an image by masking the bitmap of the mainView content with the gradient view
    // then release the pre-masked content bitmap and the gradient bitmap
    CGImageRef reflectionImageRef = CGImageCreateWithMask(self.CGImage, gradientMaskImage);
    CGImageRelease(gradientMaskImage);
	
	
	UIGraphicsBeginImageContext(CGSizeMake(self.size.width, reflectionHeight));
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextDrawImage(context, CGRectMake(0, 0, self.size.width, reflectionHeight), reflectionImageRef);
	UIImage* reflectionImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    CGImageRelease(reflectionImageRef);
	
	return reflectionImage;
}

- (UIImage *)imageWithOutline:(UIColor*)color {
	
	UIGraphicsBeginImageContext(CGSizeMake(self.size.width, self.size.height));
	
	[self drawAtPoint:CGPointZero];
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetAllowsAntialiasing(context, YES);
	CGContextSetLineWidth(context, 1.0);
	CGContextSetStrokeColorWithColor(context, color.CGColor);
	CGContextAddRect(context, CGRectMake(0, 0, self.size.width, self.size.height));
	CGContextClosePath(context);
	CGContextStrokePath(context);
	
	UIImage* imageWithOutline = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return imageWithOutline;
}

- (UIImage *)imageWithOutline:(UIColor*)color scale:(CGFloat)scale{
	
	UIGraphicsBeginImageContext(CGSizeMake(self.size.width, self.size.height));
	
	[self drawAtPoint:CGPointZero];
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetAllowsAntialiasing(context, YES);
	CGContextSetLineWidth(context, 1.0*scale);
	CGContextSetStrokeColorWithColor(context, color.CGColor);
	CGContextAddRect(context, CGRectMake(0, 0, self.size.width, self.size.height));
	CGContextClosePath(context);
	CGContextStrokePath(context);
	
	UIImage* imageWithOutline = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return imageWithOutline;
}

- (UIImage*)imageWithOutline:(UIColor*)color size:(CGSize)size{
    CGFloat imageRatio = self.size.width/self.size.height;
    CGFloat drawRatio = size.width/size.height;
    CGRect  drawRect;
    if (drawRatio >= imageRatio){
        drawRect.size.height = size.height;
        drawRect.size.width = imageRatio*size.height;
        drawRect.origin.x = (size.width - drawRect.size.width)/2.0;
        drawRect.origin.y = 0.0;
    }else{
        drawRect.size.width = size.width;
        drawRect.size.height = size.width/imageRatio;
        drawRect.origin.x = 0.0;
        drawRect.origin.y = (size.height - drawRect.size.height)/2.0;
    }
    
    UIGraphicsBeginImageContext(size);
    [self drawInRect:drawRect];
    if (color != nil){
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetAllowsAntialiasing(context, YES);
        CGContextSetLineWidth(context, 1.0);
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height));
        CGContextClosePath(context);
        CGContextStrokePath(context);
    }
    UIImage* outlineImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outlineImage;
}

- (UIImage*)imageWithBackground:(UIColor*)background size:(CGSize)size outline:(UIColor*)outline spacing:(CGFloat)spacing{
	UIGraphicsBeginImageContext(CGSizeMake(size.width, size.height));
	
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetAllowsAntialiasing(context, YES);
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, outline.CGColor);
	CGContextSetFillColorWithColor(context, background.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
	CGContextStrokeRect(context, CGRectMake(0.0, 0.0, size.width, size.height));
    
    CGRect imageRect = CGRectMake(spacing, spacing, size.width-spacing*2.0, size.height-spacing*2.0);
	[self drawInRect:imageRect];
	UIImage* imageWithBackground = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	return imageWithBackground;    
}

- (UIImage*)imageWithCornerNumber:(int)number{
	UIGraphicsBeginImageContext(CGSizeMake(self.size.width, self.size.height));
	
	CGRect imageRect = CGRectMake(0.0, 2.0, self.size.width - 2.0, self.size.height-2.0);
	[self drawInRect:imageRect];
	
	if (number > 1){
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSetAllowsAntialiasing(context, YES);
		CGContextSetLineWidth(context, 1.0);
		
		CGFloat centerX = self.size.width - 10;
		CGFloat centerY = 10;
		
		CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
		CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
		
		CGContextAddArc(context, centerX, centerY, 10, 0, M_PI*2, 1);
		CGContextClosePath(context);
		CGContextFillPath(context);
		
		CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
		CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
		
		CGRect stringRect = CGRectMake(centerX-10, centerY-10, 20, 20);
		UIFont* stringFont = [UIFont boldSystemFontOfSize:17];
		NSString* numberString = [NSString stringWithFormat:@"%d", number];
		CGSize stringSize = [numberString sizeWithFont:stringFont forWidth:stringRect.size.width lineBreakMode:UILineBreakModeTailTruncation];
		stringRect.origin.x = centerX - stringSize.width/2.0f;
		stringRect.origin.y = centerY - stringSize.height/2.0f;
		stringRect.size = stringSize;
		
		[numberString drawInRect:stringRect withFont:stringFont];
	}
	
	UIImage* imageWithOutline = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return imageWithOutline;
    
    
    
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef shadowContext = CGBitmapContextCreate(NULL, self.size.width + 10, self.size.height + 10, CGImageGetBitsPerComponent(self.CGImage), 0, 
                                                       colourSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colourSpace);
    
    CGContextSetShadowWithColor(shadowContext, CGSizeMake(5, -5), 5, [UIColor blackColor].CGColor);
    CGContextDrawImage(shadowContext, CGRectMake(0, 10, self.size.width, self.size.height), self.CGImage);
    
    CGImageRef shadowedCGImage = CGBitmapContextCreateImage(shadowContext);
    CGContextRelease(shadowContext);
    
    UIImage * shadowedImage = [UIImage imageWithCGImage:shadowedCGImage];
    CGImageRelease(shadowedCGImage);
    
    return shadowedImage;
}

- (UIImage*)imageWithBottomNumber:(int)number{
	UIGraphicsBeginImageContext(CGSizeMake(self.size.width, self.size.height));
	
	CGRect imageRect = CGRectMake(1.0, 1.0, self.size.width - 2.0, self.size.height-2.0);
	[self drawInRect:imageRect];
	
	if (number > 0){
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSetAllowsAntialiasing(context, YES);
		CGContextSetLineWidth(context, 1.0);
		CGContextSetFillColorWithColor(context,  [UIColor grayColor].CGColor);
		CGContextSetBlendMode(context, kCGBlendModeMultiply);
		
		CGRect stringRect = CGRectMake(0, self.size.height*0.75f, self.size.width, self.size.height*0.25f);
		
		CGFloat lineX = stringRect.origin.x;
		CGFloat lineY = stringRect.origin.y;
		
		CGContextMoveToPoint(context, lineX, lineY);
		
		lineX += stringRect.size.width;
		CGContextAddLineToPoint(context, lineX, lineY);
		
		lineY += stringRect.size.height;
		CGContextAddLineToPoint(context, lineX, lineY);
		
		lineX = stringRect.origin.x;
		CGContextAddLineToPoint(context, lineX, lineY);
		
		lineY = stringRect.origin.y + stringRect.size.height;
		CGContextAddLineToPoint(context, lineX, lineY);
		
		CGContextClosePath(context);
		CGContextFillPath(context);
		
		CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
		CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
		CGContextSetBlendMode(context, kCGBlendModeNormal);
		
		UIFont* stringFont = [UIFont boldSystemFontOfSize:12];
		NSString* numberString = [NSString stringWithFormat:@"%d more", number];
		CGSize stringSize = [numberString sizeWithFont:stringFont forWidth:stringRect.size.width lineBreakMode:UILineBreakModeTailTruncation];
		stringRect.origin.x = stringRect.origin.x + (stringRect.size.width - stringSize.width)/2.0f;
		stringRect.origin.y = stringRect.origin.y + (stringRect.size.height - stringSize.height)/2.0f;
		stringRect.size = stringSize;
		
		[numberString drawInRect:stringRect withFont:stringFont];
	}
	
	UIImage* imageWithOutline = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return imageWithOutline;
}

- (UIImage *)imageWithRoundCorners:(int)radius{
    int width = self.size.width;
    int height = self.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedFirst);
    
    CGContextBeginPath(context);
    CGRect rect = CGRectMake(1.0, 1.0, width-2.0, height-2.0);
	
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, radius, radius);
    float roundedRectWidth = CGRectGetWidth (rect) / radius;
    float roundedRectHeight = CGRectGetHeight (rect) / radius;
    CGContextMoveToPoint(context, roundedRectWidth, roundedRectHeight/2);
    CGContextAddArcToPoint(context, roundedRectWidth, roundedRectHeight, roundedRectWidth/2, roundedRectHeight, 1);
    CGContextAddArcToPoint(context, 0, roundedRectHeight, 0, roundedRectHeight/2, 1);
    CGContextAddArcToPoint(context, 0, 0, roundedRectWidth/2, 0, 1);
    CGContextAddArcToPoint(context, roundedRectWidth, 0, roundedRectWidth, roundedRectHeight/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
	
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, width, height), self.CGImage);
    
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    UIImage* roundCornerImage = [UIImage imageWithCGImage:imageMasked];
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageMasked);
    
    return roundCornerImage;    
}

- (UIImage *)imageWithGreyscale{
    int kRed = 1;
    int kGreen = 2;
    int kBlue = 4;
    
    int colors = kGreen;
    int m_width = self.size.width;
    int m_height = self.size.height;
    
    uint32_t *rgbImage = (uint32_t *) malloc(m_width * m_height * sizeof(uint32_t));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImage, m_width, m_height, 8, m_width * 4, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextSetShouldAntialias(context, NO);
    CGContextDrawImage(context, CGRectMake(0, 0, m_width, m_height), [self CGImage]);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // now convert to grayscale
    uint8_t *m_imageData = (uint8_t *) malloc(m_width * m_height);
    for(int y = 0; y < m_height; y++) {
        for(int x = 0; x < m_width; x++) {
            uint32_t rgbPixel=rgbImage[y*m_width+x];
            uint32_t sum=0,count=0;
            if (colors & kRed) {sum += (rgbPixel>>24)&255; count++;}
            if (colors & kGreen) {sum += (rgbPixel>>16)&255; count++;}
            if (colors & kBlue) {sum += (rgbPixel>>8)&255; count++;}
            m_imageData[y*m_width+x]=sum/count;
        }
    }
    free(rgbImage);
    
    // convert from a gray scale image back into a UIImage
    uint8_t *result = (uint8_t *) calloc(m_width * m_height *sizeof(uint32_t), 1);
    
    // process the image back to rgb
    for(int i = 0; i < m_height * m_width; i++) {
        result[i*4]=0;
        int val=m_imageData[i];
        result[i*4+1]=val;
        result[i*4+2]=val;
        result[i*4+3]=val;
    }
    
    // create a UIImage
    colorSpace = CGColorSpaceCreateDeviceRGB();
    context = CGBitmapContextCreate(result, m_width, m_height, 8, m_width * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGImageRef image = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIImage *resultUIImage = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    
    free(m_imageData);
    
    // make sure the data will be released by giving it to an autoreleased NSData
    [NSData dataWithBytesNoCopy:result length:m_width * m_height];
    
    return resultUIImage;
}

- (UIImage *)imageWithThumbnail:(CGSize)size{
    CGRect imageRect = CGRectIntegral(CGRectMake(0, 0, size.width, size.height));
    CGImageRef imageRef = self.CGImage;
    
    int bitmapBytesPerRow = imageRect.size.width*4;
    int bitmapByteCount = bitmapBytesPerRow*imageRect.size.height;
    void* bitmapData = malloc(bitmapByteCount);
    
    CGContextRef bitmap = CGBitmapContextCreate(bitmapData,
                                                imageRect.size.width,
                                                imageRect.size.height,
                                                8,
                                                bitmapBytesPerRow,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
    
    CGContextSetInterpolationQuality(bitmap, kCGInterpolationLow);
    CGContextDrawImage(bitmap, imageRect, imageRef);
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGContextRelease(bitmap);
    free(bitmapData);
    CGImageRelease(newImageRef);
    return newImage;
}

- (UIImage *)imageWithCrop:(CGRect)rect{
    CGRect imageRect = rect;
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, imageRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}


- (UIImage *)imageWithFrame:(CGSize)frameSize color:(UIColor*)frameColor{
    CGFloat imageRatio = self.size.width/self.size.height;
    CGFloat frameRatio = frameSize.width/frameSize.height;
    UIImage* frameImage = nil;
    if (frameRatio > imageRatio){
        CGFloat cropWidth = self.size.width;
        CGFloat cropHeight = self.size.width/frameRatio;
        CGFloat cropY = 0;
        if (imageRatio >= 0.5){
            cropY = (self.size.height - cropHeight)/4.0;
        }
        CGRect imageRect = CGRectMake(0, cropY, cropWidth, cropHeight);
        CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, imageRect);
        UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        frameImage = croppedImage;
    }else if (frameRatio < imageRatio){
        CGFloat cropWidth = self.size.height*frameRatio;
        CGFloat cropHeight = self.size.height;
        CGRect imageRect = CGRectMake((self.size.width-cropWidth)/2.0, 0, cropWidth, cropHeight);
        CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, imageRect);
        UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        frameImage = croppedImage;
    }else {
        frameImage = [UIImage imageWithCGImage:self.CGImage];
    }
    
    if (frameColor != nil){
        UIGraphicsBeginImageContext(CGSizeMake(frameImage.size.width, frameImage.size.height));
        [frameImage drawAtPoint:CGPointZero];
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetAllowsAntialiasing(context, YES);
        CGContextSetLineWidth(context, 1.0*frameImage.size.width/frameSize.width);
        CGContextSetStrokeColorWithColor(context, frameColor.CGColor);
        CGContextAddRect(context, CGRectMake(0, 0, frameImage.size.width, frameImage.size.height));
        CGContextClosePath(context);
        CGContextStrokePath(context);
        frameImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return frameImage;
}


@end
