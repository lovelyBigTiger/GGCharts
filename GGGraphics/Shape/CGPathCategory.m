//
//  CAAnimation+CGPathCategory.m
//  111
//
//  Created by _ | Durex on 2017/6/3.
//  Copyright © 2017年 wenhua. All rights reserved.
//

#import "CGPathCategory.h"
#import "GGChartGeometry.h"

void GGPathAddGGAxis(CGMutablePathRef ref, GGAxis axis)
{
    CGPathMoveToPoint(ref, NULL, axis.line.start.x, axis.line.start.y);
    CGPathAddLineToPoint(ref, NULL, axis.line.end.x, axis.line.end.y);
    
    CGFloat len = GGLengthLine(axis.line);
    NSInteger count = abs((int)(len / axis.sep)) + 1;
    
    for (int i = 0; i < count; i++) {
        
        CGPoint axis_pt = GGMoveStart(axis.line, axis.sep * i);
        CGPoint over_pt = GGPerpendicularMake(axis.line, axis_pt, axis.over);
        
        CGPathMoveToPoint(ref, NULL, axis_pt.x, axis_pt.y);
        CGPathAddLineToPoint(ref, NULL, over_pt.x, over_pt.y);
    }
}

void GGPathAddGGGrid(CGMutablePathRef ref, GGGrid grid)
{
    CGPoint ** result = GGGridPointAryMake(grid);
    
    for (int i = 0; i < grid.horizontal; i++) {
        
        CGPoint start = result[i][0];
        CGPoint end = result[i][grid.vertical - 1];
        
        CGPathMoveToPoint(ref, NULL, start.x, start.y);
        CGPathAddLineToPoint(ref, NULL, end.x, end.y);
    }
    
    for (int i = 0; i < grid.vertical; i++) {
        
        CGPoint start = result[0][i];
        CGPoint end = result[grid.vertical - 1][i];
        
        CGPathMoveToPoint(ref, NULL, start.x, start.y);
        CGPathAddLineToPoint(ref, NULL, end.x, end.y);
    }
    
    for (int i = 0; i < grid.horizontal; i++) {
        
        free(result[i]);
    }
    
    free(result);
}

void GGPathAddLine(CGMutablePathRef ref, GGLine line)
{
    CGPathMoveToPoint(ref, NULL, line.start.x, line.start.y);
    CGPathAddLineToPoint(ref, NULL, line.end.x, line.end.y);
}

void GGPathAddCGRect(CGMutablePathRef ref, CGRect rect)
{
    GGLine top = GGTopLineRect(rect);
    GGLine bottom = GGBottomLineRect(rect);
    GGLine left = GGLeftLineRect(rect);
    GGLine right = GGRightLineRect(rect);
    
    GGPathAddLine(ref, GGTopLineRect(rect));
    CGPathAddLineToPoint(ref, NULL, right.end.x, right.end.y);
    CGPathAddLineToPoint(ref, NULL, top.end.x, top.end.y);
    CGPathAddLineToPoint(ref, NULL, top.start.x, top.start.y);
    CGPathAddLineToPoint(ref, NULL, left.end.x, left.end.y);
    CGPathAddLineToPoint(ref, NULL, bottom.end.x, bottom.end.y);
    CGPathAddLineToPoint(ref, NULL, top.end.x, top.end.y);
}

CG_EXTERN void GGPathAddCircle(CGMutablePathRef ref, GGCircle circle)
{
    CGPathAddEllipseInRect(ref, NULL, CGRectMake(circle.center.x - circle.radius, circle.center.y - circle.radius, circle.radius * 2, circle.radius * 2));
}

CG_EXTERN void GGPathAddCircles(CGMutablePathRef ref, CGPoint *center, CGFloat radius, size_t count)
{
    for (int i = 0; i < count; i++) {
        GGCircle circle = GGCirclePointMake(center[i], radius);
        GGPathAddCircle(ref, circle);
    }
}


CG_EXTERN void GGPathAddRangeCircles(CGMutablePathRef ref, CGPoint *center, CGFloat radius, int from, int to)
{
    for (int i = from; i < to; i++) {
        GGCircle circle = GGCirclePointMake(center[i], radius);
        GGPathAddCircle(ref, circle);
    }
}

CG_EXTERN void GGPathAddSector(CGMutablePathRef ref, GGSector sector)
{
    CGPathMoveToPoint(ref, NULL, sector.center.x, sector.center.y);
    CGPathAddArc(ref, NULL, sector.center.x, sector.center.y, sector.radius, sector.start, sector.end, false);
    CGPathAddArcToPoint(ref, NULL, sector.center.x, sector.center.y, sector.center.x, sector.center.y, 100);
}

CG_EXTERN NSArray * GGPathAnimationArrayFor(GGSector sector, CGFloat duration)
{
    int frame = duration * 60;
    CGFloat arc = sector.start - sector.end;
    CGFloat frame_arc = arc / frame;
    NSMutableArray * ary = [NSMutableArray array];
    
    for (int i = 0; i < frame; i++) {
        
        CGMutablePathRef ref = CGPathCreateMutable();
        GGSector frame_sec = GGSectorCenterMake(sector.center, sector.start, sector.start - i * frame_arc, sector.radius);
        GGPathAddSector(ref, frame_sec);
        [ary addObject:(__bridge id)ref];
        CFRelease(ref);
    }
    
    return [NSArray arrayWithArray:ary];
}

CG_EXTERN void GGPathAddAnnular(CGMutablePathRef ref, GGAnnular annular)
{
    NSInteger base_x;
    NSInteger base_y;
    
    base_y = (annular.start > 0 && annular.start < M_PI) ? 1 : -1;
    base_x = (annular.start > M_PI / 2 && annular.start < M_PI * 1.5) ? -1 : 1;
    
    CGFloat start_sin_arc = sinf(annular.start);
    CGFloat start_cos_arc = cosf(annular.start);
    CGFloat start_s_x = annular.center.x + annular.radius * start_cos_arc * base_x;
    CGFloat start_s_y = annular.center.y + annular.radius * start_sin_arc * base_y;
    CGFloat start_e_x = annular.center.x + (annular.radius + annular.spa) * start_cos_arc * base_x;
    CGFloat start_e_y = annular.center.y + (annular.radius + annular.spa) * start_sin_arc * base_y;
    GGLine start_line = GGLineMake(start_s_x, start_s_y, start_e_x, start_e_y);
    
    base_x = (annular.end > 0 && annular.end < M_PI) ? 1 : -1;
    base_y = (annular.end > M_PI / 2 && annular.end < M_PI * 1.5) ? -1 : 1;
    
    CGFloat end_sin_arc = sinf(annular.end);
    CGFloat end_cos_arc = cosf(annular.end);
    CGFloat end_s_x = annular.center.x + annular.radius * end_cos_arc * base_x;
    CGFloat end_s_y = annular.center.y + annular.radius * end_sin_arc * base_y;
    CGFloat end_e_x = annular.center.x + (annular.radius + annular.spa) * end_cos_arc * base_x;
    CGFloat end_e_y = annular.center.y + (annular.radius + annular.spa) * end_sin_arc * base_y;
    
    GGLine end_line = GGLineMake(end_s_x, end_s_y, end_e_x, end_e_y);
    
    GGPathAddLine(ref, start_line);
    CGPathAddArc(ref, NULL, annular.center.x, annular.center.y, annular.radius + annular.spa, annular.start, annular.end, false);
    CGPathAddArc(ref, NULL, annular.center.x, annular.center.y, annular.radius + annular.spa, annular.end, annular.start, true);
    CGPathAddLineToPoint(ref, NULL, start_line.start.x, start_line.start.y);
    CGPathAddArc(ref, NULL, annular.center.x, annular.center.y, annular.radius, annular.start, annular.end, false);
    CGPathAddLineToPoint(ref, NULL, end_line.end.x, end_line.end.y);
    CGPathAddArc(ref, NULL, annular.center.x, annular.center.y, annular.radius + annular.spa, annular.end, annular.start, true);
    CGPathAddLineToPoint(ref, NULL, start_line.start.x, start_line.end.y);
    
//    CGPathAddArc(ref, NULL, annular.center.x, annular.center.y, annular.radius, annular.start, annular.end, false);
//    CGPathAddArc(ref, NULL, annular.center.x, annular.center.y, annular.radius + annular.spa, annular.end, annular.start, true);
//    CGPathAddArc(ref, NULL, annular.center.x, annular.center.y, annular.radius, annular.start, annular.end, false);
//    
//    CGPathAddArc(ref, NULL, annular.center.x, annular.center.y, annular.radius, annular.start, annular.end, true);
//    CGPathAddArc(ref, NULL, annular.center.x, annular.center.y, annular.radius + annular.spa, annular.start, annular.end, false);
//    CGPathAddArc(ref, NULL, annular.center.x, annular.center.y, annular.radius, annular.end, annular.start, true);
}




























































