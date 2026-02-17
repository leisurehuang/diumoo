#import <Foundation/Foundation.h>

@interface SPInvocationGrabber : NSObject {
    id _object;
    NSInvocation *_invocation;
    int frameCount;
    char **frameStrings;
    BOOL backgroundAfterForward;
    BOOL onMainAfterForward;
    BOOL waitUntilDone;
}
-(id)initWithObject:(id)obj;
-(id)initWithObject:(id)obj stacktraceSaving:(BOOL)saveStack;
@property (readonly, strong, nonatomic) id object;
@property (readonly, strong, nonatomic) NSInvocation *invocation;
@property BOOL backgroundAfterForward;
@property BOOL onMainAfterForward;
@property BOOL waitUntilDone;
-(void)invoke;
-(void)printBacktrace;
-(void)saveBacktrace;
@end

@interface NSObject (SPInvocationGrabbing)
-(id)grab;
-(id)invokeAfter:(NSTimeInterval)delta;
-(id)nextRunloop;
-(id)inBackground;
-(id)onMainAsync:(BOOL)async;
@end
