/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2022 Jean-David Gadina - www.xs-labs.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

#import "SMC.h"
#import "SMC_Reader-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@interface SMC()

@property( nonatomic, readwrite, strong ) dispatch_queue_t queue;

@end

NS_ASSUME_NONNULL_END

@implementation SMC

- ( instancetype )init
{
    if( ( self = [ super init ] ) )
    {
        self.queue = dispatch_queue_create( "com.xs-labs.SMC-Reader", DISPATCH_QUEUE_SERIAL );
    }
    
    return self;
}

- ( void )readAllKeys: ( void ( ^ )( NSArray< SMCData * > * ) )completion
{
    dispatch_async
    (
        self.queue,
        ^( void )
        {
            uint8_t                bytes[] = { 0, 0, 0, 0, 0 };
            NSData               * data    = [ [ NSData alloc ] initWithBytes: bytes length: sizeof( bytes ) ];
            NSArray< SMCData * > * items   =
            @[
                [ [ SMCData alloc ] initWithKey: @"Foo" type: SMCDataTypeTest data: data ],
                [ [ SMCData alloc ] initWithKey: @"Bar" type: SMCDataTypeTest data: data ],
            ];
            
            completion( items );
        }
    );
}

@end
