//
//  HGPageControl.m
//  HappyGift
//
//  Created by Yuhui Zhang on 5/7/12.
//  Copyright (c) 2012 Ztelic Inc. All rights reserved.
//
#import "HGPageControl.h"

#define DOT_WIDTH 6
#define DOT_SPACING 6

@implementation HGPageControl

- (void)dealloc {
    [selectedColor release];
    [deselectedColor release];
    [super dealloc];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self.backgroundColor = [UIColor clearColor];
        self.selectedColor = [UIColor darkGrayColor];
        self.deselectedColor = [UIColor lightGrayColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor clearColor];
        self.selectedColor = [UIColor darkGrayColor];
        self.deselectedColor = [UIColor grayColor];
    }
    return self;
}

-(void)setNumberOfPages:(int)number{
    numberOfPages = MAX(number, 0);
    currentPage = 0;
    //CGPoint tempCenter = self.center;
    //self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 4 + numberOfPages * DOT_WIDTH + MAX(numberOfPages - 1, 0) * DOT_SPACING, self.frame.size.height);
    //self.center = tempCenter;
    [self setNeedsDisplay];
}

-(int)numberOfPages{
    return numberOfPages;
}

-(void)setCurrentPage:(int)page{
    if (page >= numberOfPages)
        currentPage = 0;
    else
        currentPage = MAX(0, page);
    
    [self setNeedsDisplay];
}

-(int) currentPage{
    return currentPage;
}

-(void)setSelectedColor:(UIColor*)color{
    [selectedColor release];
    selectedColor = [color retain];
    [self setNeedsDisplay];
}

-(UIColor*) selectedColor{
    return selectedColor;
}

-(void)setDeselectedColor:(UIColor*)color{
    [deselectedColor release];
    deselectedColor = [color retain];
    [self setNeedsDisplay];
}

-(UIColor*) deselectedColor{
    return deselectedColor;
}

- (void)drawRect:(CGRect)rect {
    for (int page = 0; page < numberOfPages; page++) {
        CGContextRef contextRef = UIGraphicsGetCurrentContext();
        if (page == currentPage){
            CGContextSetFillColorWithColor(contextRef, selectedColor.CGColor);
        }else{
            CGContextSetFillColorWithColor(contextRef, deselectedColor.CGColor);
        }
        CGContextFillEllipseInRect(contextRef, CGRectMake(DOT_SPACING + DOT_WIDTH*page + DOT_SPACING*page, (rect.size.height - DOT_WIDTH*1.5), DOT_WIDTH, DOT_WIDTH));
    }
}
@end
