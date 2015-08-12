//
//  HGImageComposeView.m
//  HappyGift
//
//  Created by Yuhui Zhang on 7/27/12.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGImageComposeView.h"
#import "HGImageComposeItemView.h"
#import "HGImageComposeDrawingView.h"

#define kImageComposeWidgetItemWidth 120.0
#define kImageComposeWidgetItemHeight 120.0

#define kImageComposeTextItemWidth 120.0
#define kImageComposeTextItemHeight 120.0

@interface HGImageComposeView()<UIGestureRecognizerDelegate>
-(void)initSubViews;
@end

@implementation HGImageComposeView
@synthesize drawing;
@synthesize drawingColor;
@synthesize drawingWidth;

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
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handelPanGesture:)];
    [panGesture setDelegate:self];
    [self addGestureRecognizer:panGesture];
    [panGesture release];
      
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handelPinchGesture:)];  
    [pinchGesture setDelegate:self];
    [self addGestureRecognizer:pinchGesture];  
    [pinchGesture release];      
    
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handelRotationGesture:)];  
    [rotationGesture setDelegate:self];
    [self addGestureRecognizer:rotationGesture];  
    [rotationGesture release]; 
    
    imageComposeItemViews = [[NSMutableArray alloc] init];
    
    deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 24.0, 26.0)];
    [deleteButton setBackgroundImage:[UIImage imageNamed:@"compose_delete"] forState:UIControlStateNormal];
    [deleteButton setShowsTouchWhenHighlighted:YES];
    [deleteButton addTarget:self action:@selector(handleDeleteClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [deleteButton addTarget:self action:@selector(handleDeleteTouchDownAction:) forControlEvents:UIControlEventTouchDown];
    [deleteButton addTarget:self action:@selector(handleDeleteTouchUpAction:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    deleteButton.hidden = YES;
    [self addSubview:deleteButton];
    
    rotateButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 24.0, 26.0)];
    [rotateButton setBackgroundImage:[UIImage imageNamed:@"compose_rotate"] forState:UIControlStateNormal];
    [rotateButton setShowsTouchWhenHighlighted:YES];
    [rotateButton addTarget:self action:@selector(handleRotateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    rotateButton.hidden = YES;
    [self addSubview:rotateButton];
}

- (void)dealloc{
    [deleteButton release];
    [rotateButton release];
    [imageComposeItemViews release];
    [imageComposeDrawingView release];
    [drawingColor release];
    [super dealloc];
}

+ (HGImageComposeView*)createImageComposeView;{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGImageComposeView"
                                                      owner:self
                                                    options:nil];
    return [nibViews objectAtIndex:0];    
}

- (void)handleDeleteClickAction:(id)sender{
    [self removeSelected];
}

- (void)handleDeleteTouchDownAction:(id)sender{
    dragingDeleteButton = YES;
}

- (void)handleDeleteTouchUpAction:(id)sender{
   dragingDeleteButton = NO;
}

- (void)handleRotateButtonAction:(id)sender{
    
}

- (void)setDrawing:(BOOL)theDrawing{
    if (drawing != theDrawing){
        drawing = theDrawing;
        if (drawing){
            if (imageComposeDrawingView == nil){
                imageComposeDrawingView = [[HGImageComposeDrawingView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
                
                imageComposeDrawingView.drawingColor = drawingColor;
                imageComposeDrawingView.drawingWidth = drawingWidth;
                
                [self addSubview:imageComposeDrawingView];
                
                if (outlineImageComposeItemView != nil){
                    [self sendSubviewToBack:outlineImageComposeItemView];
                }
                [self sendSubviewToBack:imageComposeDrawingView];
                [self sendSubviewToBack:[imageComposeItemViews lastObject]];
            }
            imageComposeDrawingView.userInteractionEnabled = YES;
        }else{
            imageComposeDrawingView.userInteractionEnabled = NO;
        }
        [self setNeedsDisplay];
    }
}

- (void)setDrawingColor:(UIColor *)theDrawingColor{
    if (drawingColor != nil){
        [drawingColor release];
        drawingColor = nil;
    }
    
    drawingColor = [theDrawingColor retain];
    if (imageComposeDrawingView != nil){
        imageComposeDrawingView.drawingColor = drawingColor;
    }
}

- (void)setDrawingWidth:(CGFloat)theDrawingWidth{
    drawingWidth = theDrawingWidth;
    if (imageComposeDrawingView != nil){
        imageComposeDrawingView.drawingWidth = drawingWidth;
    }
}

-(void)handelPanGesture:(UIPanGestureRecognizer*)recognizer{
    CGPoint translationForGesture = [recognizer translationInView:self];
    CGPoint translation = CGPointZero;
    if (recognizer.state == UIGestureRecognizerStateBegan){
        translation = translationForGesture;
        if (dragingRotateButton == YES){
            dragingRotateOrigin = rotateButton.center;
            dragingRotateCenter = [currentImageComposeItemView convertPoint:currentImageComposeItemView.innerCenter toView:self];
            dragingRotateDistanceOrigin = sqrtf((dragingRotateCenter.x - dragingRotateOrigin.x)*(dragingRotateCenter.x - dragingRotateOrigin.x) + (dragingRotateCenter.y - dragingRotateOrigin.y)*(dragingRotateCenter.y - dragingRotateOrigin.y)); 
            dragingRotateVectorXOrigin = (dragingRotateOrigin.x - dragingRotateCenter.x);
            dragingRotateVectorYOrigin = (dragingRotateOrigin.y - dragingRotateCenter.y);
            lastScale = 1.0;
            lastRotation = 0.0;
        }
    }else{
        translation = CGPointMake(translationForGesture.x - lastTranslation.x, translationForGesture.y - lastTranslation.y);
    }
    if (dragingRotateButton == YES){
        if (recognizer.state == UIGestureRecognizerStateChanged){
            CGPoint pointForGesture = [recognizer locationInView:self];
            CGFloat dragingRotateDistanceCurrent = sqrtf((pointForGesture.x - dragingRotateCenter.x)*(pointForGesture.x - dragingRotateCenter.x) + (pointForGesture.y - dragingRotateCenter.y)*(pointForGesture.y - dragingRotateCenter.y)); 
            CGFloat scaleForGesture = dragingRotateDistanceCurrent/dragingRotateDistanceOrigin;
            CGFloat scale = (scaleForGesture - lastScale)/lastScale;
            
            CGFloat dragingRotateVectorXCurrent = (pointForGesture.x - dragingRotateCenter.x);
            CGFloat dragingRotateVectorYCurrent = (pointForGesture.y - dragingRotateCenter.y);
            CGFloat rotateForGestureCosValue = (dragingRotateVectorXOrigin*dragingRotateVectorXCurrent + dragingRotateVectorYOrigin*dragingRotateVectorYCurrent) / (sqrtf(dragingRotateVectorXOrigin*dragingRotateVectorXOrigin + dragingRotateVectorYOrigin*dragingRotateVectorYOrigin) * sqrtf(dragingRotateVectorXCurrent*dragingRotateVectorXCurrent + dragingRotateVectorYCurrent*dragingRotateVectorYCurrent)); 
            
            CGFloat rotateForGesture = acosf(rotateForGestureCosValue);
            CGFloat rotateCrossForGesture = dragingRotateVectorXOrigin*dragingRotateVectorYCurrent - dragingRotateVectorYOrigin*dragingRotateVectorXCurrent;
            if (rotateCrossForGesture < 0){
                rotateForGesture = M_PI*2.0 - rotateForGesture;
            }
            CGFloat rotate = rotateForGesture - lastRotation;
            
//            float currentImageComposeItemViewScale = [[currentImageComposeItemView.layer valueForKeyPath: @"transform.scale"] floatValue];
//            if (scale > 1.0 ){
//                if (currentImageComposeItemViewScale*scale <= 2.0){
//                    [currentImageComposeItemView performZoom:scale];
//                    lastScale = scaleForGesture;
//                }
//            }else if (scale < 1.0){
//                if (currentImageComposeItemViewScale*scale >= 0.5){
//                    [currentImageComposeItemView performZoom:scale];
//                    lastScale = scaleForGesture;
//                }
//            }
            [currentImageComposeItemView performZoom:scale];
            lastScale = scaleForGesture;
            
            [currentImageComposeItemView performRotate:rotate];
            lastRotation = rotateForGesture;
            
            [self adjustDeleteButton];
            [self adjustRotateButton];
            
            
        }
    }else if (currentImageComposeItemView != nil){
        [currentImageComposeItemView performTranslate:translation];
        [self adjustDeleteButton];
        [self adjustRotateButton];
    }
    lastTranslation = translationForGesture;
    
    if (recognizer.state == UIGestureRecognizerStateEnded||
        recognizer.state == UIGestureRecognizerStateCancelled||
        recognizer.state == UIGestureRecognizerStateFailed){
        dragingRotateButton = NO;
    }
}

-(void)handelPinchGesture:(UIPinchGestureRecognizer*)recognizer{
    CGFloat scaleForGesture = [recognizer scale];
    CGFloat scale = 1.0;
    if (recognizer.state == UIGestureRecognizerStateBegan){
        scale = (scaleForGesture - 1.0);
    }else{
        scale = (scaleForGesture - lastScale)/lastScale;
    }
    if (currentImageComposeItemView != nil){
//        float currentImageComposeItemViewScale = [[currentImageComposeItemView.layer valueForKeyPath: @"transform.scale"] floatValue];
//        if (scale > 1.0 && currentImageComposeItemViewScale*scale > 2.0){
//            return;
//        }
//        if (scale < 1.0 && currentImageComposeItemViewScale*scale < 0.5){
//            return;
//        }
        [currentImageComposeItemView performZoom:scale];
        [self adjustDeleteButton];
        [self adjustRotateButton];
    }
    lastScale = scaleForGesture;
}

-(void)handelRotationGesture:(UIRotationGestureRecognizer*)recognizer{
    CGFloat rotationForGesture = [recognizer rotation];
    CGFloat rotation = 0.0;
    if (recognizer.state == UIGestureRecognizerStateBegan){
        rotation = rotationForGesture;
    }else{
        rotation = rotationForGesture - lastRotation;
    }
    if (currentImageComposeItemView != nil){
        [currentImageComposeItemView performRotate:rotation];
        [self adjustDeleteButton];
        [self adjustRotateButton];
    }
    lastRotation = rotationForGesture;
}

- (void)addCanvas:(UIImage*)canvas{
    HGImageComposeItemView* imageComposeItemView = [[HGImageComposeItemView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
    
    CGFloat imageRatio = canvas.size.width/canvas.size.height;
    CGFloat viewRatio = self.frame.size.width/self.frame.size.height;
    CGFloat compareRatio = fabsf(imageRatio - viewRatio)/viewRatio;
    if (compareRatio < 0.2f){
        imageComposeItemView.contentMode = UIViewContentModeScaleAspectFill;
    }else{
        imageComposeItemView.contentMode = UIViewContentModeScaleAspectFit;
    }
    [imageComposeItemView setImage:canvas];
    imageComposeItemView.hidden = YES;
    [imageComposeItemViews addObject:imageComposeItemView];
    [self addSubview:imageComposeItemView];
    [self sendSubviewToBack:imageComposeItemView];
    [imageComposeItemView release];
    
    CATransform3D transform = imageComposeItemView.layer.transform;
    transform = CATransform3DTranslate(transform, imageComposeItemView.bounds.size.width/2.0, imageComposeItemView.bounds.size.height/2.0, 0);
    transform = CATransform3DScale(transform, 1.5, 1.5, 1.0);
    transform = CATransform3DTranslate(transform, -imageComposeItemView.bounds.size.width/2.0, -imageComposeItemView.bounds.size.height/2.0, 0);
    transform = CATransform3DRotate(transform, -M_PI*0.66, 0, 0, 1);
    imageComposeItemView.layer.transform = transform;
    
    imageComposeItemView.hidden = NO;
    [UIView animateWithDuration:0.3 
                          delay:0.3 
                        options:UIViewAnimationOptionCurveEaseInOut 
                     animations:^{
                         imageComposeItemView.layer.transform = CATransform3DIdentity;
                     } 
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)addWidget:(UIImage*)widget{
    HGImageComposeItemView* imageComposeItemView = [[HGImageComposeItemView alloc] initWithFrame:CGRectMake((self.frame.size.width - kImageComposeWidgetItemWidth)/2.0, (self.frame.size.height - kImageComposeWidgetItemHeight)/2.0, kImageComposeWidgetItemWidth, kImageComposeWidgetItemHeight)];
    [imageComposeItemView setImage:widget];
    imageComposeItemView.hidden = YES;
    imageComposeItemView.selected = YES;
    currentImageComposeItemView.selected = NO;
    currentImageComposeItemView = imageComposeItemView;
    [imageComposeItemViews insertObject:imageComposeItemView atIndex:0];
    [self addSubview:imageComposeItemView];
    [self bringSubviewToFront:deleteButton];
    [self bringSubviewToFront:rotateButton];
    [imageComposeItemView release];
    
    deleteButton.hidden = YES;
    rotateButton.hidden = YES;
    
    CATransform3D transform = imageComposeItemView.layer.transform;
    transform = CATransform3DTranslate(transform, imageComposeItemView.bounds.size.width/2.0, imageComposeItemView.bounds.size.height/2.0, 0);
    transform = CATransform3DScale(transform, 1.5, 1.5, 1.0);
    transform = CATransform3DTranslate(transform, -imageComposeItemView.bounds.size.width/2.0, -imageComposeItemView.bounds.size.height/2.0, 0);
    transform = CATransform3DRotate(transform, -0.6, 0, 0, 1);
    imageComposeItemView.layer.transform = transform;
    
    imageComposeItemView.hidden = NO;
    [UIView animateWithDuration:0.3 
                          delay:0.3 
                        options:UIViewAnimationOptionCurveEaseInOut 
                     animations:^{
                        imageComposeItemView.layer.transform = CATransform3DIdentity;
                     } 
                     completion:^(BOOL finished) {
                         [self adjustDeleteButton];
                         [self adjustRotateButton];
                     }];
}

- (void)addText:(UIImage*)text{
    HGImageComposeItemView* imageComposeItemView = [[HGImageComposeItemView alloc] initWithFrame:CGRectMake((self.frame.size.width - kImageComposeTextItemWidth)/2.0, (self.frame.size.height - kImageComposeTextItemHeight)/2.0, kImageComposeTextItemWidth, kImageComposeTextItemHeight)];
    [imageComposeItemView setImage:text];
    imageComposeItemView.hidden = YES;
    imageComposeItemView.selected = YES;
    currentImageComposeItemView.selected = NO;
    currentImageComposeItemView = imageComposeItemView;
    [imageComposeItemViews insertObject:imageComposeItemView atIndex:0];
    [self addSubview:imageComposeItemView];
    [self bringSubviewToFront:deleteButton];
    [self bringSubviewToFront:rotateButton];
    [imageComposeItemView release];
    
    deleteButton.hidden = YES;
    rotateButton.hidden = YES;
    
    CATransform3D transform = imageComposeItemView.layer.transform;
    transform = CATransform3DTranslate(transform, imageComposeItemView.bounds.size.width/2.0, imageComposeItemView.bounds.size.height/2.0, 0);
    transform = CATransform3DScale(transform, 1.5, 1.5, 1.0);
    transform = CATransform3DTranslate(transform, -imageComposeItemView.bounds.size.width/2.0, -imageComposeItemView.bounds.size.height/2.0, 0);
    transform = CATransform3DRotate(transform, -0.6, 0, 0, 1);
    imageComposeItemView.layer.transform = transform;
    
    imageComposeItemView.hidden = NO;
    [UIView animateWithDuration:0.3 
                          delay:0.3 
                        options:UIViewAnimationOptionCurveEaseInOut 
                     animations:^{
                         imageComposeItemView.layer.transform = CATransform3DIdentity;
                     } 
                     completion:^(BOOL finished) {
                         [self adjustDeleteButton];
                         [self adjustRotateButton];
                     }];    
}

- (void)addOutline:(UIImage*)outline{
    
    if (outlineImageComposeItemView != nil){
        if (outlineImageComposeItemView.image == outline){
            return;
        }
        [outlineImageComposeItemView removeFromSuperview];
        [imageComposeItemViews removeObject:outlineImageComposeItemView];
        outlineImageComposeItemView = nil;
    }
    
    HGImageComposeItemView* imageComposeItemView = [[HGImageComposeItemView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [imageComposeItemView setImage:outline];
    imageComposeItemView.hidden = YES;
    imageComposeItemView.selected = NO;
    outlineImageComposeItemView = imageComposeItemView;
    [imageComposeItemViews insertObject:imageComposeItemView atIndex:[imageComposeItemViews count] - 1];
    [self addSubview:imageComposeItemView];
    [self sendSubviewToBack:outlineImageComposeItemView];
    if (imageComposeDrawingView != nil){
        [self sendSubviewToBack:imageComposeDrawingView];
    }
    [self sendSubviewToBack:[imageComposeItemViews lastObject]];
    [imageComposeItemView release];
    
    deleteButton.hidden = YES;
    rotateButton.hidden = YES;
    
    CATransform3D transform = imageComposeItemView.layer.transform;
    transform = CATransform3DTranslate(transform, imageComposeItemView.bounds.size.width/2.0, imageComposeItemView.bounds.size.height/2.0, 0);
    transform = CATransform3DScale(transform, 1.5, 1.5, 1.0);
    transform = CATransform3DTranslate(transform, -imageComposeItemView.bounds.size.width/2.0, -imageComposeItemView.bounds.size.height/2.0, 0);
    imageComposeItemView.layer.transform = transform;
    
    imageComposeItemView.hidden = NO;
    [UIView animateWithDuration:0.3 
                          delay:0.3 
                        options:UIViewAnimationOptionCurveEaseInOut 
                     animations:^{
                         imageComposeItemView.layer.transform = CATransform3DIdentity;
                     } 
                     completion:^(BOOL finished) {
                         [self adjustDeleteButton];
                         [self adjustRotateButton];
                     }]; 
}

- (void)removeSelected{
    if (currentImageComposeItemView != nil && currentImageComposeItemView != [imageComposeItemViews lastObject]){
        [currentImageComposeItemView removeFromSuperview];
        [imageComposeItemViews removeObject:currentImageComposeItemView];
        currentImageComposeItemView = nil;
        deleteButton.hidden = YES;
        rotateButton.hidden = YES;
    }
}

- (void)clearSelected{
    if (currentImageComposeItemView != nil){
        currentImageComposeItemView.selected = NO;
        currentImageComposeItemView = nil;
        deleteButton.hidden = YES;
        rotateButton.hidden = YES;
    }
}

- (HGImageComposeItemView*)selectImageComposeItemView:(CGPoint)point{
    for (HGImageComposeItemView* imageComposeItemView in imageComposeItemViews){
        CGPoint viewPoint = [imageComposeItemView convertPoint:point fromView:self];
        if (outlineImageComposeItemView != imageComposeItemView &&
            [imageComposeItemView pointInside:viewPoint withEvent:nil]){
            return imageComposeItemView;
        }
    }
    return nil;
}

- (void)adjustDeleteButton{
    if (currentImageComposeItemView != nil){
        CGRect deleteButtonFrame = deleteButton.frame;
        CGPoint point = [currentImageComposeItemView convertPoint:currentImageComposeItemView.topCorner toView:self];
        point.x -= deleteButtonFrame.size.width/2.0;
        point.y -= deleteButtonFrame.size.height/2.0;
        deleteButtonFrame.origin = point;
        deleteButton.frame = deleteButtonFrame;
        
        if (currentImageComposeItemView != [imageComposeItemViews lastObject]){
            deleteButton.hidden = NO;
        }
    }
}

- (void)adjustRotateButton{
    if (currentImageComposeItemView != nil){
        CGRect rotateButtonFrame = rotateButton.frame;
        CGPoint point = [currentImageComposeItemView convertPoint:currentImageComposeItemView.bottomCorner toView:self];
        point.x -= rotateButtonFrame.size.width/2.0;
        point.y -= rotateButtonFrame.size.height/2.0;
        rotateButtonFrame.origin = point;
        rotateButton.frame = rotateButtonFrame;
        
        if (currentImageComposeItemView != [imageComposeItemViews lastObject]){
            rotateButton.hidden = NO;
        }
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if (drawing == NO){
        if (CGPointEqualToPoint(currentHitTestPoint, point) == NO){
            currentHitTestPoint = point;
            if (deleteButton.hidden == NO){
                CGPoint viewPoint = [deleteButton convertPoint:point fromView:self];
                if ([deleteButton pointInside:viewPoint withEvent:nil]){
                    dragingDeleteButton = YES;
                    return deleteButton;
                }
            }
            if (rotateButton.hidden == NO){
                CGPoint viewPoint = [rotateButton convertPoint:point fromView:self];
                if ([rotateButton pointInside:viewPoint withEvent:nil]){
                    dragingRotateButton = YES;
                    return rotateButton;
                }
            }
            HGImageComposeItemView* imageComposeItemView = [self selectImageComposeItemView:point];
            if (imageComposeItemView != currentImageComposeItemView){
                currentImageComposeItemView.selected = NO;
                deleteButton.hidden = YES;
                rotateButton.hidden = YES;
                currentImageComposeItemView = imageComposeItemView;
                if (currentImageComposeItemView != [imageComposeItemViews lastObject]){
                    currentImageComposeItemView.selected = YES;
                    [self bringSubviewToFront:currentImageComposeItemView];
                    [self bringSubviewToFront:deleteButton];
                    [self bringSubviewToFront:rotateButton];
                    [self adjustDeleteButton];
                    [self adjustRotateButton];
                }
            }
        }
    }
    return [super hitTest:point withEvent:event];
}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (drawing == YES){
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (dragingDeleteButton == YES){
        return NO;
    }
    if (dragingRotateButton == YES){
        if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
            return YES;
        }
    }
    return YES;
}
@end
