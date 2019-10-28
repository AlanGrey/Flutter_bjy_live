//
//  BJPUMacro.h
//  BJVideoPlayerUI
//
//  Created by DLM on 2017/4/26.
//
//

#ifndef BJPUMacro_h
#define BJPUMacro_h

#define BJPUScreenSize ([UIScreen mainScreen].bounds.size)
#define BJPUScreenWidth (BJPUScreenSize.width < BJPUScreenSize.height ? BJPUScreenSize.width : BJPUScreenSize.height)
#define BJPUScreenHeight (BJPUScreenSize.width > BJPUScreenSize.height ? BJPUScreenSize.width : BJPUScreenSize.height)

#define kStaticMargin   (15.f)

#define BJPUOnePixel (1.0/[UIScreen mainScreen].scale)

#endif /* BJPUMacro_h */
