//
//  AkordeonView.m
//  Akordeon Demo
//
//  Created by Anil Can Baykal on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AkordeonView.h"

@implementation AkordeonView

@synthesize delegate = _delegate, datasource = _datasource;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor]; 
        _currentHeaderHeight = kDeafultAkordeonTitleHeight; 
        headers = [NSMutableArray new]; 
    }
    return self;
}

/*
-(CGPoint)originOfHeaderAtSection:(NSInteger)section{
    if (section == 0) return CGPointZero; 
    else return 44 * section; 
}
*/

-(UIButton*)defaultHeaderForSection:(NSInteger)section{
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor darkGrayColor]; 
    
    // REMOVE ME
    CGFloat _y = (section==0)?0 : section * kDeafultAkordeonTitleHeight;
    button.frame = CGRectMake(0, _y, self.bounds.size.width, kDeafultAkordeonTitleHeight);
    button.tag = section; 
    
    if( [_datasource respondsToSelector:@selector(titleForSection:forAkordeon:)])
        [button setTitle: [_datasource titleForSection:section forAkordeon:self]
                forState:UIControlStateNormal];
    
#ifdef DEBUG
    else
        [button setTitle:[NSString stringWithFormat:@"%@ %d" , @"Section", section]
                forState:UIControlStateNormal];
#endif
        
    [button addTarget:self action:@selector(changeSection:) forControlEvents:UIControlEventTouchUpInside]; 
    
    return button; 
}

-(CGFloat)calculateTotalHeight{
    int totalSection = [_datasource numbersOfSectionInAkordeon:self]; 
    return  totalSection * _currentHeaderHeight; 
    /*
    if (![_datasource respondsToSelector:@selector(heightForSection)]){
        return kDeafultAkordeonTitleHeight * totalSection;         
    } else {
    
        CGFloat totalHeight = 0.;
        for ( int section = 0; section < totalSection; section++){            
            totalHeight += [_datasource heightForSection];                                         
        }
        return totalHeight; 
    }*/
}


-(void)reloadData{
            
#ifdef DEBUG    
    NSAssert(_delegate 	!= nil, @"delegate cannot be null");
    NSAssert(_datasource !=nil, @"datasource cannot be null");
#endif
        
    [headers removeAllObjects]; 
    CGFloat currentY = 0.;

    if ([_datasource respondsToSelector:@selector(heightForSection)])
        _currentHeaderHeight = [_datasource heightForSection]; 
    
    int totalSection = [_datasource numbersOfSectionInAkordeon:self]; 
    for ( int section = 0; section < totalSection; section++){        
                                
        UIButton * button = [self defaultHeaderForSection:section];                
        button.frame = CGRectMake(0, currentY, self.frame.size.width, _currentHeaderHeight);
        [self addSubview:button]; 
        currentY += _currentHeaderHeight; 
        [headers addObject:button]; 
        
        if ( section == 0) {            
            _currentView = [_datasource viewAtSection:section forAkordeon:self]; 
            _currentView.frame = CGRectMake(0, currentY, _currentView.frame.size.width, _currentView.frame.size.height);
            [self insertSubview:_currentView belowSubview:button]; 
            currentY += _currentView.frame.size.height;              
        }        
    }
    
    _currentSection = 0;     
}

-(void)changeSection:(UIButton*)sectionButton{
    [self changeSection:sectionButton.tag animated:YES];     
}

-(void)changeSection:(NSInteger)section animated:(BOOL)animated{
      
    if (section == _currentSection) return;
    
    UIView * header = [headers objectAtIndex:section];
    CGPoint origin = header.frame.origin; 
    origin.y += header.bounds.size.height;     
    
    UIView * view = [_datasource viewAtSection:section forAkordeon:self];
    CGRect newFrame = view.frame; 
    newFrame.origin = origin;
    view.frame= newFrame; 
    
    // add below first header so no subview blocks headers
    [self insertSubview:view belowSubview:[headers objectAtIndex:0]]; 
        
    //animate rest
    //calculate new center delta
    CGFloat height = self.bounds.size.height - [self calculateTotalHeight];

    // want new view to slide from top
    if(_currentSection > section) {
        updateOriginY(view, -1*height);
    }

    
    
    [UIView beginAnimations:nil context:nil]; 
    [UIView setAnimationDelegate:self]; 
    [UIView setAnimationDidStopSelector:@selector(sectionDidChange)];
    [UIView setAnimationDuration:0.2]; 
        
        
    int coef = 1; 
    
    if (_currentSection > section){
        //current View asagiya
       
        for ( int i = section+1 ;  i <= _currentSection; i++){
            
            UIView * headerNext = [headers objectAtIndex:i]; 
            CGPoint c2 = headerNext.center; 
            c2.y += height; 
            headerNext.center = c2; 
        }
        
        CGRect anim = view.frame; 
        anim.origin.y += height; 
        view.frame = anim; 
        
        
    } else {
        //newView yukari
        for ( int i = section ;  i > _currentSection; i--){
            UIView * headerNext = [headers objectAtIndex:i]; 
            CGPoint c2 = headerNext.center; 
            c2.y -= height; 
            headerNext.center = c2; 
        }
        
        CGRect anim = view.frame; 
        anim.origin.y -= height; 
        view.frame = anim; 
        coef = -1;
    }
    
    CGRect t =  _currentView.frame; 
    t.origin.y += coef * height;
    _currentView.frame = t; 
    
    [UIView commitAnimations];
    
    //[_currentView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.5];
    
    _currentView = view; 
    _currentSection = section; 
    
}

-(void)sectionDidChange{
    //hmmm
    NSLog(@"yeah IT did change"); 
}

@end
