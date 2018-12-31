/**
 * 图表
 * @author 郑业强 2018-12-18 创建文件
 */

#import "BookChart.h"
#import "CHART_EVENT.h"
#import "BookChartHUD.h"

// 图表left
#define CHART_L countcoordinatesX(15)
// 图表top
#define CHART_T countcoordinatesX(5)
// 图表width
#define CHART_W (SCREEN_WIDTH - CHART_L * 2)
// 图表height
#define CHART_H countcoordinatesX(80)
// 线条粗
#define CHART_LINE 1.f / [UIScreen mainScreen].scale / 2.f
// 圆点大小
#define CHART_POINT_W countcoordinatesX(5)
// 字体大小
#define CHART_FONT [UIFont systemFontOfSize:AdjustFont(8) weight:UIFontWeightLight]

#pragma mark - 声明
@interface BookChart()

@property (nonatomic, strong) NSMutableArray<NSNumber *> *numbers;
@property (nonatomic, strong) NSMutableArray<NSValue *> *points;
@property (nonatomic, strong) BookChartHUD *bhud;

@end


#pragma mark - 实现
@implementation BookChart


- (void)initUI {
    
}


#pragma mark - 点击
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self routerEventWithName:CHART_CHART_TOUCH_BEGIN data:nil];
    [self getIndexWithPoint:touches];
    [self.bhud setHidden:false];
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self getIndexWithPoint:touches];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self routerEventWithName:CHART_CHART_TOUCH_END data:nil];
    [self.bhud setHidden:true];
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self routerEventWithName:CHART_CHART_TOUCH_CANNEL data:nil];
    [self.bhud setHidden:true];
}
// 获取当前点
- (void)getIndexWithPoint:(NSSet<UITouch *> *)touches {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    CGPoint point = [[touches anyObject] locationInView:self];
    point = [self convertPoint:point toView:window];
    point = CGPointMake(point.x -= CHART_L, point.y);

    NSInteger count = ({
        NSInteger count = 0;
        if (_segmentIndex == 0) {
            count = 7;
        } else if (_segmentIndex == 1) {
            NSString *str = [NSString stringWithFormat:@"%ld-%02ld-01", _subModel.year, _subModel.month];
            NSDate *date = [NSDate dateWithYMD:str];
            count = [date daysInMonth];
        } else if (_segmentIndex == 2) {
            count = 12;
        }
        count;
    });
    CGFloat left = point.x;
    left += CHART_W / (count - 1) / 2;
    NSInteger index = (NSInteger)(left / (CHART_W / (count - 1)));


    CGRect frame = [self.points[index] CGRectValue];
    frame = [self convertRect:frame toView:window];
    [self.bhud setPointFrame:frame];
    
    
    
    [self.bhud setModels:({
        NSMutableArray *arrm = [NSMutableArray array];
        for (BookListModel *model in self.model.list) {
            if (_segmentIndex == 0) {
                if (model.week_day == (index + 1)) {
                    [arrm addObject:model];
                }
            } else if (_segmentIndex == 1) {
                if (model.day == (index + 1)) {
                    [arrm addObject:model];
                }
            } else if (_segmentIndex == 2) {
                if (model.month == (index + 1)) {
                    [arrm addObject:model];
                }
            }
        }
        arrm;
    })];


}


#pragma mark - set
- (void)setModel:(BKModel *)model {
    _model = model;
    if (_segmentIndex == 0) {
        NSMutableArray<NSNumber *> *arrm = [NSMutableArray array];
        for (int i=0; i<7; i++) {
            [arrm addObject:@(0)];
        }
        for (BookListModel *submodel in model.list) {
            NSInteger index = submodel.week_day - 1;
            CGFloat number = [arrm[index] floatValue];
            number += submodel.price;
            [arrm replaceObjectAtIndex:index withObject:@(number)];
        }
        [self setNumbers:arrm];
    } else if (_segmentIndex == 1) {
        NSString *str = [NSString stringWithFormat:@"%ld-%02ld-01", _subModel.year, _subModel.month];
        NSDate *date = [NSDate dateWithYMD:str];
        NSInteger count = [date daysInMonth];
        NSMutableArray<NSNumber *> *arrm = [NSMutableArray array];
        for (int i=0; i<count; i++) {
            [arrm addObject:@(0)];
        }
        for (BookListModel *submodel in model.list) {
            NSInteger index = submodel.day - 1;
            CGFloat number = [arrm[index] floatValue];
            number += submodel.price;
            [arrm replaceObjectAtIndex:index withObject:@(number)];
        }
        [self setNumbers:arrm];
    } else if (_segmentIndex == 2) {
        NSMutableArray<NSNumber *> *arrm = [NSMutableArray array];
        for (int i=0; i<12; i++) {
            [arrm addObject:@(0)];
        }
        for (BookListModel *submodel in model.list) {
            NSInteger index = submodel.month - 1;
            CGFloat number = [arrm[index] floatValue];
            number += submodel.price;
            [arrm replaceObjectAtIndex:index withObject:@(number)];
        }
        [self setNumbers:arrm];
    }
    [self setNeedsDisplay];
}


#pragma mark - 绘图
- (void)drawRect:(CGRect)rect {
    [kColor_White setFill];
    UIRectFill(rect);
    
    // 顶部
    [self drawLine:CGPointMake(CHART_L, CHART_T) point2:CGPointMake(CHART_W + CHART_L, CHART_T) color:kColor_Text_Gary isDash:NO];
    // 底部
    [self drawLine:CGPointMake(CHART_L, CHART_T + countcoordinatesX(80)) point2:CGPointMake(CHART_W + CHART_L, CHART_T + countcoordinatesX(80)) color:kColor_Text_Black isDash:NO];
    
    
    if (_segmentIndex == 0) {
        [self drawWeek];
    }
    else if (_segmentIndex == 1) {
        [self drawMonth];
    }
    else if (_segmentIndex == 2) {
        [self drawYear];
    }
}

// 周
- (void)drawWeek {
    [self.points removeAllObjects];
    
    
    NSMutableArray *lines = [[NSMutableArray alloc] init];
//    NSMutableArray<NSValue *> *points = [[NSMutableArray alloc] init];
    CGFloat maxPrice = [[self.numbers valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat avgPrice = maxPrice / 7.f;
    
    
    NSString *str = [NSString stringWithFormat:@"%ld-%02ld-%02ld", _subModel.year, _subModel.month, _subModel.day];
    NSDate *date = [NSDate dateWithYMD:str];
    NSDate *firDate = [date offsetDays:-(_subModel.week_day - 1)];
    
    
    // 平均线
    CGFloat avgH = CHART_H - CHART_H / maxPrice * avgPrice;
    [self drawLine:CGPointMake(CHART_L, avgH) point2:CGPointMake(CHART_W + CHART_L, avgH) color:kColor_Text_Gary isDash:YES];
    
    CGFloat count = 7;
    for (int i=0; i<count; i++) {
        CGFloat width = CHART_W / (count - 1);
        CGFloat left = CHART_L - CHART_POINT_W / 2 + width * i;
        CGFloat value = [self.numbers[i] floatValue];
        CGFloat valueH = value != 0 ? CHART_H / maxPrice * [self.numbers[i] floatValue] : 0;
        CGFloat top = CHART_T + countcoordinatesX(80) - CHART_POINT_W / 2 - valueH;
        
        CGPoint linePoint = CGPointMake(left + CHART_POINT_W / 2, top + CHART_POINT_W / 2);
        [lines addObject:@(linePoint)];
        
        CGRect pointFrame = CGRectMake(left, top, CHART_POINT_W, CHART_POINT_W);
        [self.points addObject:@(pointFrame)];
        
        // 文字
        NSDate *now = [firDate offsetDays:i];
        NSString *str = [NSString stringWithFormat:@"%02ld-%02ld", now.month, now.day];
        [self drawText:str color:kColor_Text_Black frame:({
            CGFloat textW = [str sizeWithMaxSize:CGSizeMake(MAXFLOAT, MAXFLOAT) font:CHART_FONT].width;
            CGFloat top = CHART_T + countcoordinatesX(80) + countcoordinatesX(5);
            if (i == 0) {
                left += textW / 2.f;
            } else if (i == (count - 1)) {
                left -= textW / 2.f - CHART_POINT_W;
            } else {
                left += CHART_POINT_W / 2;
            }
            CGRectMake(left - textW / 2.f, top, textW, countcoordinatesX(20));
        })];
    }
    
    // 折线
    [self drawLine:kColor_Text_Gary points:lines];
    for (int i=0; i<self.numbers.count; i++) {
        CGFloat value = [self.numbers[i] floatValue];
        UIColor *color = value == 0 ? kColor_White : kColor_Main_Color;
        
        NSValue *point = self.points[i];
        CGRect pointFrame = [point CGRectValue];
        [self drawArc:kColor_Text_Gary fill:color frame:pointFrame];
    }
    
}
// 月
- (void)drawMonth {
    [self.points removeAllObjects];
    
    NSString *str = [NSString stringWithFormat:@"%ld-%02ld-01", _subModel.year, _subModel.month];
    NSDate *date = [NSDate dateWithYMD:str];
    NSInteger count = [date daysInMonth];
    
    
    NSMutableArray *lines = [[NSMutableArray alloc] init];
    CGFloat maxPrice = [[self.numbers valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat avgPrice = maxPrice / count;
    
    
    // 平均线
    CGFloat avgH = CHART_H - CHART_H / maxPrice * avgPrice;
    [self drawLine:CGPointMake(CHART_L, avgH) point2:CGPointMake(CHART_W + CHART_L, avgH) color:kColor_Text_Gary isDash:YES];

    
    for (int i=0; i<count; i++) {
        CGFloat width = CHART_W / (count - 1);
        CGFloat left = CHART_L - CHART_POINT_W / 2 + width * i;
        CGFloat value = [self.numbers[i] floatValue];
        CGFloat valueH = value != 0 ? CHART_H / maxPrice * [self.numbers[i] floatValue] : 0;
        CGFloat top = CHART_T + countcoordinatesX(80) - CHART_POINT_W / 2 - valueH;
        
        CGPoint linePoint = CGPointMake(left + CHART_POINT_W / 2, top + CHART_POINT_W / 2);
        [lines addObject:@(linePoint)];
        
        CGRect pointFrame = CGRectMake(left, top, CHART_POINT_W, CHART_POINT_W);
        [self.points addObject:@(pointFrame)];
        
        // 文字
        if (i == 0 || (i + 1) % 3 == 0) {
            NSString *str = [NSString stringWithFormat:@"%d", i + 1];
            [self drawText:str color:kColor_Text_Black frame:({
                CGFloat textW = [str sizeWithMaxSize:CGSizeMake(MAXFLOAT, MAXFLOAT) font:CHART_FONT].width;
                CGFloat top = CHART_T + countcoordinatesX(80) + countcoordinatesX(5);
                if (i == 0) {
                    left += textW / 2.f;
                } else if (i == (count - 1)) {
                    left -= textW / 2.f - CHART_POINT_W;
                } else {
                    left += CHART_POINT_W / 2;
                }
                CGRectMake(left - textW / 2.f, top, textW, countcoordinatesX(20));
            })];
        }
    }
    
    // 折线
    [self drawLine:kColor_Text_Gary points:lines];
    for (int i=0; i<self.numbers.count; i++) {
        CGFloat value = [self.numbers[i] floatValue];
        UIColor *color = value == 0 ? kColor_White : kColor_Main_Color;
        
        NSValue *point = self.points[i];
        CGRect pointFrame = [point CGRectValue];
        [self drawArc:kColor_Text_Gary fill:color frame:pointFrame];
    }
    
    
    
}
// 年
- (void)drawYear {
    [self.points removeAllObjects];
    
    
    
    
    NSMutableArray *lines = [[NSMutableArray alloc] init];
    NSMutableArray<NSValue *> *points = [[NSMutableArray alloc] init];
    CGFloat maxPrice = [[self.numbers valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat avgPrice = maxPrice / 12.f;
    
    
    // 平均线
    CGFloat avgH = CHART_H - CHART_H / maxPrice * avgPrice;
    [self drawLine:CGPointMake(CHART_L, avgH) point2:CGPointMake(CHART_W + CHART_L, avgH) color:kColor_Text_Gary isDash:YES];
    
    CGFloat count = 12;
    for (int i=0; i<count; i++) {
        CGFloat width = CHART_W / (count - 1);
        CGFloat left = CHART_L - CHART_POINT_W / 2 + width * i;
        CGFloat value = [self.numbers[i] floatValue];
        CGFloat valueH = value != 0 ? CHART_H / maxPrice * [self.numbers[i] floatValue] : 0;
        CGFloat top = CHART_T + countcoordinatesX(80) - CHART_POINT_W / 2 - valueH;
        
        CGPoint linePoint = CGPointMake(left + CHART_POINT_W / 2, top + CHART_POINT_W / 2);
        [lines addObject:@(linePoint)];
        
        CGRect pointFrame = CGRectMake(left, top, CHART_POINT_W, CHART_POINT_W);
        [self.points addObject:@(pointFrame)];
        
        // 文字
        if (i == 0 || (i + 1) % 3 == 0) {
            NSString *str = [NSString stringWithFormat:@"%d月", i + 1];
            [self drawText:str color:kColor_Text_Black frame:({
                CGFloat textW = [str sizeWithMaxSize:CGSizeMake(MAXFLOAT, MAXFLOAT) font:CHART_FONT].width;
                CGFloat top = CHART_T + countcoordinatesX(80) + countcoordinatesX(5);
                if (i == 0) {
                    left += textW / 2.f;
                } else if (i == (count - 1)) {
                    left -= textW / 2.f - CHART_POINT_W;
                } else {
                    left += CHART_POINT_W / 2;
                }
                CGRectMake(left - textW / 2.f, top, textW, countcoordinatesX(20));
            })];
        }
    }
    
    // 折线
    [self drawLine:kColor_Text_Gary points:lines];
    for (int i=0; i<self.numbers.count; i++) {
        CGFloat value = [self.numbers[i] floatValue];
        UIColor *color = value == 0 ? kColor_White : kColor_Main_Color;
        
        NSValue *point = self.points[i];
        CGRect pointFrame = [point CGRectValue];
        [self drawArc:kColor_Text_Gary fill:color frame:pointFrame];
    }
    
    
}



// 绘制线条
- (void)drawLine:(CGPoint)point point2:(CGPoint)point2 color:(UIColor *)color isDash:(BOOL)isDash {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextMoveToPoint(ctx, point.x, point.y);
    CGContextAddLineToPoint(ctx, point2.x, point2.y);
    [color set];
    if (isDash == YES) {
        CGFloat lengths[] = {5, 5, 5, 5};
        CGContextSetLineDash(ctx, 0, lengths, 4);
    } else {
        CGFloat lengths[] = {};
        CGContextSetLineDash(ctx, 0, lengths, 0);
    }
    CGContextSetLineWidth(ctx, CHART_LINE);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextStrokePath(ctx);
}
// 绘制文字
- (void)drawText:(NSString *)text color:(UIColor *)color frame:(CGRect)frame {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    
    NSDictionary *dict = @{NSForegroundColorAttributeName: color,
                           NSFontAttributeName: CHART_FONT,
                           NSParagraphStyleAttributeName: style
                           };
    [text drawInRect:frame withAttributes:dict];
}
// 绘制圆形
- (void)drawArc:(UIColor *)line fill:(UIColor *)fill frame:(CGRect)frame {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, CHART_LINE);
    CGContextSetStrokeColorWithColor(context, line.CGColor);
    CGContextSetFillColorWithColor(context, fill.CGColor);
    CGContextAddEllipseInRect(context, frame);
    CGContextDrawPath(context, kCGPathFillStroke);
}
// 绘制折现
- (void)drawLine:(UIColor *)color points:(NSArray<NSValue *> *)arr {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    for (int i=0; i<arr.count; i++) {
        CGPoint point = [arr[i] CGPointValue];
        if (i == 0) {
            CGContextMoveToPoint(ctx, point.x, point.y);
        } else {
            CGContextAddLineToPoint(ctx, point.x, point.y);
        }
    }
    CGFloat lengths[] = {};
    [color set];
    CGContextSetLineDash(ctx, 0, lengths, 0);
    CGContextSetLineWidth(ctx, CHART_LINE);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextStrokePath(ctx);
}


#pragma mark - get
- (BookChartHUD *)bhud {
    if (!_bhud) {
        _bhud = [BookChartHUD init];
        [[UIApplication sharedApplication].keyWindow addSubview:_bhud];
    }
    return _bhud;
}
- (NSMutableArray<NSValue *> *)points {
    if (!_points) {
        _points = [NSMutableArray array];
    }
    return _points;
}


@end
