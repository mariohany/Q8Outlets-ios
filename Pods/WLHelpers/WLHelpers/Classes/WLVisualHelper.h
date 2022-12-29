//
//  WLVisualHelper.h
//  WLHelpers
//
//  Created by Lesya Verbina on 6/1/16.
//  Copyright © 2016 Wonderslab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 Enum of different directions in visual space.
 */
typedef enum {
    WLDirectionUp,
    WLDirectionDown,
    WLDirectionLeft,
    WLDirectionRight
} WLDirection;

@interface WLVisualHelper : NSObject

#pragma mark - Views

/**
 *  For rounding fully rounded views in bulk. Corner radius will be set as half of view's height.
 *
 *  @param view UIView to be rounded.
 */
+ (void)fullRoundThisView:(UIView *)view;

/**
 *  For rounding fully rounded views in bulk. Corner radius will be set as half of view's height.
 *
 *  @param views UIViews to be rounded.
 */
+ (void)fullRoundThisViews:(NSArray *)views;


/**
 *  For rounding not fully circular round views.
 *
 *  @param view   UIView to be rounded.
 *  @param radius Corner radius.
 */
+ (void)roundThisView:(UIView *)view
               radius:(float)radius;

/**
 *  For rounding not fully circular round views in bulk.
 *
 *  @param views  UIViews to be rounded.
 *  @param radius Corner radius.
 */
+ (void)roundThisViews:(NSArray *)views
                radius:(float)radius;

/**
 *  For rounding only rignt side of the view.
 *
 *  @param view UIView to be rounded.
 */
+ (void)roundRightOfView:(UIView *)view;

/**
 *  For rounding only left side of the view.
 *
 *  @param view UIView to be rounded.
 */
+ (void)roundLeftOfView:(UIView *)view;

/**
 *  For rounding only top side of the view.
 *
 *  @param view UIVIew to be rounded.
 */
+ (void)roundTopOfView:(UIView *)view;

/**
 *  For rounding only bottom side of the view.
 *
 *  @param view         UIVIew to be rounded.
 */
+ (void)roundBottomOfView:(UIView *)view;

/**
 *  For rounding only rignt side of the view for specific radius.
 *
 *  @param view UIView to be rounded.
 *  @param cornerRadius Corner radius.
 */
+ (void)roundRightOfView:(UIView *)view cornerRadius:(float)cornerRadius;

/**
 *  For rounding only left side of the view for specific radius.
 *
 *  @param view UIView to be rounded.
 *  @param cornerRadius Corner radius.
 */
+ (void)roundLeftOfView:(UIView *)view cornerRadius:(float)cornerRadius;

/**
 *  For rounding only top side of the view for specific radius.
 *
 *  @param view UIVIew to be rounded.
 *  @param cornerRadius Corner radius.
 */
+ (void)roundTopOfView:(UIView *)view cornerRadius:(float)cornerRadius;

/**
 *  For rounding only bottom side of the view for specific radius.
 *
 *  @param view         UIVIew to be rounded.
 *  @param cornerRadius Corner radius.
 */
+ (void)roundBottomOfView:(UIView *)view cornerRadius:(float)cornerRadius;

/**
 *  Adding shadow to view's layer, as lag-free as possible.
 *
 *  @param view            UIView which will recieve shadow.
 *  @param hardShadow      Regulates opacity, if set to YES will be more opaque, if set to NO will be less opaque.
 *  @param shouldRasterize Controls rasterization of the layer, only needed for non-rectangular views. If set to YES, layer will be rasterized, if set to NO, shadow will recieve rectangular shadowPath.
 */
+ (void)addDropShadowToView:(UIView *)view
                 hardShadow:(BOOL)hardShadow
            shouldRasterize:(BOOL)shouldRasterize;

/**
 *  Adding shadow to view's layer, as lag-free as possible. 
 *  To many views at once, using the same options.
 *
 *  @param views           UIViews which will recieve shadow.
 *  @param hardShadow      Regulates opacity, if set to YES will be more opaque, if set to NO will be less opaque.
 *  @param shouldRasterize Controls rasterization of the layer, only needed for non-rectangular views. If set to YES, layer will be rasterized, if set to NO, shadow will recieve rectangular shadowPath.
 */
+ (void)addDropShadowToViews:(NSArray <UIView *> *)views
                 hardShadow:(BOOL)hardShadow
            shouldRasterize:(BOOL)shouldRasterize;

/**
 *  Adding shadow to view's layer, as lag-free as possible, and also rounding corners.
 *
 *  @param view            UIView which will recieve shadow.
 *  @param radius          Corner radius.
 *  @param hardShadow      Regulates opacity, if set to YES will be more opaque, if set to NO will be less opaque.
 *  @param shouldRasterize Controls rasterization of the layer, only needed for non-rectangular views. If set to YES, layer will be rasterized, if set to NO, shadow will recieve rectangular shadowPath.
 */
+ (void)addDropShadowAndRoundThisView:(UIView *)view
                         cornerRadius:(float)radius
                           hardShadow:(BOOL)hardShadow
                      shouldRasterize:(BOOL)shouldRasterize;

/**
 *  Adding shadow to view's layer, as lag-free as possible, and also rounding corners. 
 *  To may views at once, using the same options.
 *
 *  @param views           UIViews which will recieve shadow.
 *  @param radius          Corner radius.
 *  @param hardShadow      Regulates opacity, if set to YES will be more opaque, if set to NO will be less opaque.
 *  @param shouldRasterize Controls rasterization of the layer, only needed for non-rectangular views. If set to YES, layer will be rasterized, if set to NO, shadow will recieve rectangular shadowPath.
 */
+ (void)addDropShadowAndRoundThisViews:(NSArray <UIView *> *)views
                         cornerRadius:(float)radius
                           hardShadow:(BOOL)hardShadow
                      shouldRasterize:(BOOL)shouldRasterize;

/**
 *  Adding shadow to view's layer, as lag-free as possible, and also rounding corners to half the view's height.
 *
 *  @param view            UIView which will recieve shadow.
 *  @param hardShadow      Regulates opacity, if set to YES will be more opaque, if set to NO will be less opaque.
 *  @param shouldRasterize Controls rasterization of the layer, only needed for non-rectangular views. If set to YES, layer will be rasterized, if set to NO, shadow will recieve rectangular shadowPath.
 */
+ (void)addDropShadowAndFullyRoundThisView:(UIView *)view
                           hardShadow:(BOOL)hardShadow
                      shouldRasterize:(BOOL)shouldRasterize;

/**
 *  Adding shadow to view's layer, as lag-free as possible, and also rounding corners to half the view's height.
 *  To many views at once, using the same options.
 *
 *  @param views           UIViews which will recieve shadow.
 *  @param hardShadow      Regulates opacity, if set to YES will be more opaque, if set to NO will be less opaque.
 *  @param shouldRasterize Controls rasterization of the layer, only needed for non-rectangular views. If set to YES, layer will be rasterized, if set to NO, shadow will recieve rectangular shadowPath.
 */
+ (void)addDropShadowAndFullyRoundThisViews:(NSArray <UIView *> *)views
                                hardShadow:(BOOL)hardShadow
                           shouldRasterize:(BOOL)shouldRasterize;

/**
 *  Removes shadow from view's layer.
 *
 *  @param view UIView which will lose shadow.
 */
+ (void)removeShadowFromView:(UIView *)view;

/**
 *  For adding borders to view's layer.
 *
 *  @param view  UIView that will have border.
 *  @param color Border color.
 *  @param width Border width, in real pixels.
 */
+ (void)addBorderToView:(UIView *)view
                  color:(UIColor *)color
                  width:(CGFloat)width;

/**
 *  For adding borders to view's layer in bulk.
 *
 *  @param views UIViews that will have borders.
 *  @param color Border color.
 *  @param width Border width, in real pixels.
 */
+ (void)addBorderToViews:(NSArray *)views
                   color:(UIColor *)color
                   width:(CGFloat)width;

#pragma mark - Gradients

/**
 *  For adding linear vertical gradients to a view.
 *
 *  @param view   UIView which will have a vertical gradient background.
 *  @param colors Array of color objects in correspondance to order of colors in the gradient, from top to bottom.
 */
+ (void)addVerticalGradientToView:(UIView *)view
                   gradientColors:(NSArray<UIColor *> *)colors;

/**
 *  For adding linear horizontal gradient to a view.
 *
 *  @param view   UIView which will have a horizontal gradient background.
 *  @param colors Array of color objects in correspondance to order of colors in the gradient, from left to right.
 */
+ (void)addHorizontalGradientToView:(UIView *)view
                     gradientColors:(NSArray<UIColor *> *)colors;

/**
 *  Creates image object from linear gradient, horizontal or vertical. Can be usefull for tabbars and navigation bars.
 *
 *  @param colors   Array of color objects in correspondance to order of colors in the gradient, from left to right (or from top to bottom).
 *  @param vertical Flag for vertical/horizontal gradient.
 *  @param size     Size of the resulting image.
 *
 *  @return Image object from linear gradient.
 */
+ (UIImage *)imageWithGradientColors:(NSArray<UIColor *> *)colors
                  gradientIsVertical:(BOOL)vertical
                           imageSize:(CGSize)size;

#pragma mark - Text fields

/**
 *  Customization of text field placeholder color. Needs to be applied after any changes to placeholder text, uses attributed strings.
 *
 *  @param textField Text field which placeholder color will be changed.
 *  @param color     New placeholder color.
 */
+ (void)changePlaceholderColorOfTextField:(UITextField *)textField
                                    color:(UIColor *)color;

/**
 *  Customization of text fields placeholder color in bulk. Needs to be applied after any changes to placeholder text, uses attributed strings.
 *
 *  @param textFields Text fields which placeholder color will be changed.
 *  @param color      New placeholder color.
 */
+ (void)changePlaceholderColorOfTextFields:(NSArray *)textFields
                                     color:(UIColor *)color;

/**
 *  For customizing label character spacing.
 *
 *  @param label   Label, which character spacing will be affected.
 *  @param spacing New spacing, in character points.
 */
+ (void)setCharacterSpacingToLabel:(UILabel *)label
                           spacing:(float)spacing;

/**
 *  Left padding for text field, one of the uses is for "plain" text fields that can simulate "bordered" appearence.
 *
 *  @param padding   Amount of padding to add.
 *  @param textField Text field which will have padding.
 */
+ (void)addLeftPadding:(float)padding
           toTextField:(UITextField *)textField;

/**
 *  Left padding for text fields in bulk, one of the uses is for "plain" text fields that can simulate "bordered" appearence.
 *
 *  @param padding    Amount of padding to add.
 *  @param textFields Text fields which will have padding.
 */
+ (void)addLeftPadding:(float)padding
          toTextFields:(NSArray *)textFields;

/**
 *  Icon inside text field, either left view or right view.
 *
 *  @param name       Name of the icon in bundle.
 *  @param templatize Templatize imare or use original. If set to YES, image will be taken as a shilouette.
 *  @param textField  Text field which will have icon.
 *  @param toTheLeft  Left side of text field, or right side of text field?
 */
+ (void)addIconWithName:(NSString *)name
             templatize:(BOOL)templatize
            toTextField:(UITextField *)textField
             toLeftView:(BOOL)toTheLeft;

#pragma mark - Labels

/**
 Make part of attributed title bold insibe of a label. The method is quite primitive
 simple search for targeted text is performed.

 @param textToFind Text to make bold.
 @param label Label to change.
 */
+ (void)makeTextBold:(NSString *)textToFind inLabel:(UILabel *)label;

#pragma mark - Buttons

/**
 *  Center button icon and text, on top of each other. Text and icon on top of text.
 *
 *  @param button  Button which will have centered image and title.
 *  @param spacing Spacing between button's image and title.
 */
+ (void)centerButtonIconOverText:(UIButton *)button
                         spacing:(CGFloat)spacing;

/**
 *  Padding between buttons image and its title.
 *
 *  @param button Button which needs padding.
 *  @param spacing Spacing between button's image and title.
 */
+ (void)addPaddingToImageInButton:(UIButton *)button
                          spacing:(CGFloat)spacing;

/**
 Move icon from the right side to the left side.

 @param button Button with the icon to flip.
 */
+ (void)moveButtonIconToLeft:(UIButton *)button;

/**
 *  Padding between buttons image and its title, in bulk.
 *
 *  @param buttons Array of buttons which needs padding.
 *  @param spacing Spacing between button's image and title.
 */
+ (void)addPaddingToImageInButtons:(NSArray<UIButton *> *)buttons
                           spacing:(CGFloat)spacing;

/**
 *  Make button's title shrink font size depending on width.
 *
 *  @param button     Button to modify font size.
 *  @param multilined Flag that determines if title has more than one line.
 */
+ (void)makeButtonFontDynamicSize:(UIButton *)button
                  multilinedTitle:(BOOL)multilined;

/**
 *  Make button's title shrink font size depending on width. For many buttons.
 *
 *  @param buttons     Buttons to modify font size.
 */
+ (void)makeButtonsFontDynamicSize:(NSArray<UIButton *> *)buttons;

#pragma mark - Images

/**
 *  For UIImageViews that have template images. Image inside UIImageView will be treated as a mask, and tint color will be applied to it.
 *
 *  @param imageView Image view that contains template image.
 *  @param color     Color of template image.
 */
+ (void)templatizeImageView:(UIImageView *)imageView
                  withColor:(UIColor *)color;

/**
 *  For UIImageViews that have template images, templatizing in bulk. Image inside UIImageView will be treated as a mask, and tint color will be applied to it.
 *
 *  @param imageViews   Image views that contain template image.
 *  @param color        Color of template image.
 */
+ (void)templatizeImageViews:(NSArray *)imageViews
                   withColor:(UIColor *)color;

/**
 *  For UIImageViews that have template images. Image inside UIImageView will be treated as a mask, and tint color will be applied to it.
 *  Tint color will be an average color of the image itself.
 *
 *  @param imageView Image view that contains template image.
 */
+ (void)templatizeImageViewWithAverageColor:(UIImageView *)imageView;

/**
 *  For UIImageViews that have template images. Image inside UIImageView will be treated as a mask, and tint color will be applied to it.
 *  Tint color will be an average color of the image itself.
 *
 *  @param imageViews Image views that contain template image.
 */
+ (void)templatizeImageViewsWithAverageColor:(NSArray<UIImageView *> *)imageViews;

/**
 *  For buttons that have template images. Image in button will be treated as a mask, and tint color will be applied to it.
 *
 *  @param button   Button with template image.
 *  @param color    Color of template image.
 */
+ (void)templatizeButton:(UIButton *)button
               withColor:(UIColor *)color;

/**
 *  For buttons that have template images, templatizing in bulk. Image in button will be treated as a mask, and tint color will be applied to it.
 *
 *  @param buttons  Buttons with template image.
 *  @param color    Color of template image.
 */
+ (void)templatizeButtons:(NSArray *)buttons
                withColor:(UIColor *)color;

/**
 *  Draw triangle with equal sides, facing in a specified way.
 *
 *  @param view              View to triangleize.
 *  @param triangleDirection Triangle direction.
 *  @param color             Triangle color.
 */
+ (void)transformViewtoTriange:(UIView *)view
               facingDirection:(WLDirection)triangleDirection
                 triangleColor:(UIColor *)color;

/**
 *  Average image color.
 *
 *  @param image Image from which to extract color.
 *
 *  @return Average image color.
 */
+ (UIColor *)averageColorOfImage:(UIImage *)image;

/**
 *  Strip image from EXIF flags and rotate the pixels.
 *  to the correct orientation instead.
 *
 *  @param image Image to rotate.
 *
 *  @return Rotated image.
 */
+ (UIImage *)rotateImageToDefaultOrientation:(UIImage *)image;

/**
 *  Compile bezier path from array of CGPoints. CGPoints are stored.
 *  as NSValues.
 *
 *  @param arrayOfPoints Array of CGPoints.
 *
 *  @return Resulting bezier path.
 */
+ (UIBezierPath *)pathFromPoints:(NSArray<NSValue *> *)arrayOfPoints;

/**
 *  Draw image from path, using specified stroke color. Can be drawn over transparend
 *  field, or over background image.
 *
 *  @param path            Path to stroke.
 *  @param color     Stroke color.
 *  @param inputImage Optional background image over which stroke will be made.
 *
 *  @return Image with strocked path.
 */
+ (UIImage *)strokePath:(UIBezierPath *)path
            strokeColor:(UIColor *)color
        backgroundImage:(UIImage *)inputImage;

#pragma mark - Scroll views

/**
 Calculates the scale factor of scroll view that will make 
 the image view fit the scroll view.

 @param imageView Image view to fit.
 @param scrollView Scroll view in which image view has to fit.
 */
+ (void)sizeImageView:(UIImageView *)imageView
      toFitScrollView:(UIScrollView *)scrollView;

/**
 Calculates content insets of scroll view that will make
 the inmage view be centered in the scroll view.
 
 @param imageView Image view to center.
 @param scrollView Scroll view in which image view has to center.
 */
+ (void)centerImageView:(UIImageView *)imageView
           inScrollView:(UIScrollView *)scrollView;

#pragma mark - Table views

/**
 *  For getting intended height of cells from .xib files.
 *
 *  @param nibName Name of the .xib file that contains cell.
 *
 *  @return Height of cell, as set in .xib file.
 */
+ (float)customCellHeightFromNibName:(NSString *)nibName;

/**
 *  For making cells with zero separator inset. (thanks Apple :|)
 *
 *  @param cell Cell that will have zero inset.
 */
+ (void)makeCellZeroInset:(UITableViewCell *)cell;

/**
 *  For using smooth animation of refresh controllers, without using UITableViewController.
 *
 *  @param refreshControl RefreshControl that will be added to table view.
 *  @param tableView      Table view that will have refresh control.
 */
+ (void)addRefreshControll:(UIRefreshControl *)refreshControl
               toTableView:(UITableView *)tableView;

#pragma mark - Misc

/**
 *  For animated tabbar toggle.
 *
 *  @param visible    Flag to show/hide tabbar.
 *  @param controller Controller that will have tabbar.
 *  @param animated   Flag to animate change.
 *  @param completion Block to be executed on completion of toggle.
 */
+ (void)setTabBarVisible:(BOOL)visible
            onController:(UIViewController *)controller
                animated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

/**
 *  Real 1 pixel for retinas.
 *
 *  @return Real 1 pixel, in points, for current display.
 */
+ (CGFloat)real1Px;

/**
 *  Transforming hex string to UIColor object.
 *
 *  @param hexString Color string in hex, with or without # sign.
 *
 *  @return UIColor object for hex color.
 */
+ (UIColor *)colorFromHexString:(NSString *)hexString;


@end
