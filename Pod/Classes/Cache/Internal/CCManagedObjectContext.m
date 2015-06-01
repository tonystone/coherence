//
// Created by Tony Stone on 4/30/15.
//

#import "CCManagedObjectContext.h"
#import "CCWriteAheadLog.h"
#import "CCBackingStore.h"

#import <TraceLog/TraceLog.h>

@implementation CCManagedObjectContext {
        NSManagedObjectContextConcurrencyType concurrencyType;

        CCManagedObjectContext __weak * parent;
        NSThread                      * ownerThread;

        dispatch_queue_t concurrencyQueue;
        dispatch_group_t concurrencyGroup;

        struct _flags {
            // State management
            unsigned int _blockWaitMode:1;

            unsigned int _reserved:30;
        } __block _flags;
    }

    - (id)init {
        return [self initWithConcurrencyType: NSConfinementConcurrencyType parent: nil];
    }

    - (instancetype)initWithConcurrencyType:(NSManagedObjectContextConcurrencyType)ct {
        return [self initWithConcurrencyType: ct parent: nil];
    }

    - (instancetype)initWithConcurrencyType:(NSManagedObjectContextConcurrencyType)ct parent:(CCManagedObjectContext *)aParent {
        
        LogInfo(@"Initializing '%@' instance...", NSStringFromClass([self class]));

        //
        // Initialize the parent in the correct queue and thread.
        //
        dispatch_queue_t tmpConcurrencyQueue = nil;
        dispatch_group_t tmpConcurrencyGroup = nil;

        __block id blockSelf = self;

        switch (ct) {
            case NSMainQueueConcurrencyType:
            {
                tmpConcurrencyQueue = dispatch_get_main_queue();
                tmpConcurrencyGroup = dispatch_group_create();

                if ([NSThread isMainThread]) {
                    blockSelf = [super initWithConcurrencyType: NSConfinementConcurrencyType];
                } else {
                    dispatch_sync(tmpConcurrencyQueue, ^{
                        blockSelf = [super initWithConcurrencyType: NSConfinementConcurrencyType];
                    });
                }
                
                break;
            }
            case NSPrivateQueueConcurrencyType:
            {
                NSString * queueName = [@"com.climate.moc.concurrencyQueue." stringByAppendingString: [[NSUUID UUID] UUIDString]];

                tmpConcurrencyQueue = dispatch_queue_create([queueName cStringUsingEncoding: NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
                tmpConcurrencyGroup = dispatch_group_create();

                dispatch_sync(tmpConcurrencyQueue, ^{
                    blockSelf = [super initWithConcurrencyType: NSConfinementConcurrencyType];

                    [blockSelf setName: queueName];
                });
                break;
            }
            case NSConfinementConcurrencyType:
            default:
            {
                tmpConcurrencyQueue = nil;
                blockSelf = [super initWithConcurrencyType: NSConfinementConcurrencyType];
                break;
            }
        }
        self = blockSelf;
        //
        // Note: these are assigned after the super init above
        //       for the class.  This is because Apple will
        //       sometimes return a different instance of the
        //       class depending on the implementation.
        //
        //       With the current implementation of
        //       NSManagedObjectContext this is not
        //       strictly needed but this code is like
        //       this to protect against change.
        //
        self->concurrencyType  = ct;
        self->parent           = aParent;
        self->ownerThread      = [NSThread currentThread];

        self->concurrencyQueue = tmpConcurrencyQueue;
        self->concurrencyGroup = tmpConcurrencyGroup;

        self->_flags._blockWaitMode = FALSE;

        if (self->parent) {
            //
            // Note: Registration of notifications is safe
            //       to do on any thread.
            [self->parent registerListener: self];
        }
        LogInfo(@"'%@' instance initialized.", NSStringFromClass([self class]));
        
        return self;
    }

    - (void) dealloc {
        if (parent) {
            [parent unregisterListener: self];
        }
        //
        // If we get deallocated before the children,
        // we need to make sure we unregister all the
        // children because they wont be able to call
        // back.
        //
        [[NSNotificationCenter defaultCenter] removeObserver: self];
    }

    - (void)performBlock:(void (^)())block {
        NSParameterAssert(block != nil);
        
        NSAssert(concurrencyQueue != nil, @"Can only use -performBlock: on an NSManagedObjectContext that was created with a queue.");

        dispatch_group_async(concurrencyGroup, concurrencyQueue, ^{

            @autoreleasepool {
                self->_flags._blockWaitMode = TRUE;

                block();

                self->_flags._blockWaitMode = FALSE;
            }
        });
    }

    - (void)performBlockAndWait:(void (^)())block {
        NSParameterAssert(block != nil);
        
        NSAssert(concurrencyQueue != nil, @"Can only use -performBlockAndWait: on an NSManagedObjectContext that was created with a queue.");

        if (concurrencyType == NSMainQueueConcurrencyType && [NSThread isMainThread]) {
            self->_flags._blockWaitMode = TRUE;
            
            block();
            
            self->_flags._blockWaitMode = FALSE;
        } else {
            dispatch_group_async(concurrencyGroup, concurrencyQueue, ^{

                @autoreleasepool {
                    self->_flags._blockWaitMode = TRUE;

                    block();

                    self->_flags._blockWaitMode = FALSE;
                }
            });
            dispatch_group_wait(concurrencyGroup, DISPATCH_TIME_FOREVER);
        }
    }

    - (NSTimeInterval)stalenessInterval {
        return [super stalenessInterval];
    }

    - (void)setStalenessInterval:(NSTimeInterval)stalenessInterval {
          [super setStalenessInterval: stalenessInterval];
    }

    - (NSArray *) executeFetchRequest:(NSFetchRequest *)request error:(NSError * *)error {
        NSEntityDescription * entity = [request entity];

        if (!entity) {
            @throw [NSException exceptionWithName: @"FetchRequest Exception" reason: @"NSFetchRequest without an NSEntityDescription" userInfo: nil];
        }

        return [super executeFetchRequest: request error: error];
    }

    - (void) refreshObject:(NSManagedObject *)object mergeChanges:(BOOL)mergeChanges {
        [super refreshObject: object mergeChanges: mergeChanges];
    }

    - (void)registerListener:(CCManagedObjectContext *)listener {
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleContextDidSaveNotification:) name: NSManagedObjectContextDidSaveNotification object: listener];
    }

    - (void)unregisterListener:(CCManagedObjectContext *)listener {
        [[NSNotificationCenter defaultCenter] removeObserver: self name: NSManagedObjectContextDidSaveNotification object: listener];
    }

    - (void) handleContextDidSaveNotification:(NSNotification *) notification {

        void (^mergeChanges)(void) = ^{

            @autoreleasepool {

                [[self undoManager] disableUndoRegistration];

                // Merge the changes into our main context
                [self mergeChangesFromContextDidSaveNotification: notification];

                NSError * error = nil;

                if (![self save:&error]) {
                    @throw [NSException exceptionWithName: @"Merge Exception" reason: [error localizedDescription] userInfo: @{@"error": error}];
                }

                [[self undoManager] enableUndoRegistration];
            }
        };

        if (concurrencyType == NSConfinementConcurrencyType) {
            
            if ([NSThread currentThread] == ownerThread) {
                mergeChanges();
            } else {
                [self performSelector: @selector(handleContextDidSaveNotification:) onThread: ownerThread withObject: notification waitUntilDone: NO];
            }
        } else {
            [self performBlock:mergeChanges];
        }
    }

@end