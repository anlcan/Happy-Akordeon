//
//  AkordeonView.h
//  Akordeon Demo
//
//  Created by Anil Can Baykal on 1/10/12.
//  Copyright (c) 2012 Happy Blue Duck http://happyblueduck.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AkordeonView; 

#define kDeafultAkordeonTitleHeight		44. // default header can be a toolbar...

#define updateOriginY(view,deltaY)	{CGRect tmp = view.frame; tmp.origin.y += deltaY; view.frame = tmp;}
#define updateOriginX(view,deltaX)	{CGRect tmp = view.frame; tmp.origin.x += deltaX; view.frame = tmp;}

typedef enum {
    AkordeonViewVertical,
    AkordeonViewHorizontal    
} AkordeonViewType;

//UITableView UITextViewDelegate
@protocol AkordeonDataSource  <NSObject>

@required
-(NSInteger)numbersOfSectionInAkordeon:(AkordeonView*)akordeon;
-(UIView*)viewAtSection:(NSInteger)section forAkordeon:(AkordeonView*)akordeon; //views will not be cached, and this method will be called everytime akordeon changes view
-(NSString*)titleForSection:(NSInteger)section forAkordeon:(AkordeonView*)akordeon; 

@optional
-(UIView*)headerAtSection:(NSInteger)section forAkordeon:(AkordeonView*)akordeon; 
-(UIImage*)imageForSection:(NSInteger)section forAkordeon:(AkordeonView*)akordeon; 
-(CGFloat)heightForSection; //Default is titleheight..

@end

@protocol AkordeonDelegate <NSObject>

@optional
// the exact order of view change
-(void)akordeon:(AkordeonView*)akordeon didSelectSection:(NSInteger)section; 
-(BOOL)shouldChangeViewToSection:(NSInteger)section;
-(void)akordeon:(AkordeonView*)akordeon sectionWillAppear:(NSInteger)section; 
-(void)akordeon:(AkordeonView*)akordeon sectionDidAppear:(NSInteger)section; 

@end


@interface AkordeonView : UIView{
    
    AkordeonViewType _type; 
    
    id<AkordeonDelegate> _delegate; 
    id<AkordeonDataSource> _datasource; 
    
    NSMutableArray * headers; 
    
    
    UIView * 	_currentView; 
    CGFloat		_currentHeaderHeight; 
    NSInteger 	_currentSection; 
}

@property(nonatomic, assign) id<AkordeonDelegate> delegate; 
@property(nonatomic, assign) id<AkordeonDataSource> datasource; 

-(void)changeSection:(NSInteger)section animated:(BOOL)animated; 

-(void)reloadData;
@end
