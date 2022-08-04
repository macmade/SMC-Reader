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
#import "SMC-Internal.h"
#import "SMC_Reader-Swift.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wfour-char-constants"

const uint32_t kSMCKeyNKEY = '#KEY';
const uint32_t kSMCKeyACID = 'ACID';

#pragma clang diagnostic push

@import IOKit;

NS_ASSUME_NONNULL_BEGIN

@interface SMC()

@property( nonatomic, readwrite, strong ) dispatch_queue_t queue;
@property( nonatomic, readwrite, assign ) io_connect_t     connection;

- ( BOOL )callSMCFunction: ( uint32_t )function input: ( const SMCParamStruct * )input output: ( SMCParamStruct * )output;
- ( BOOL )readSMCKeyInfo: ( SMCKeyInfoData * )info forKey: ( uint32_t )key;
- ( BOOL )readSMCKey: ( uint32_t * )key atIndex: ( uint32_t )index;
- ( BOOL )readSMCKey: ( uint32_t )key buffer: ( uint8_t * )buffer maxSize: ( uint32_t * )maxSize keyInfo: ( SMCKeyInfoData * _Nullable )keyInfo;
- ( uint32_t )readSMCKeyCount;
- ( uint32_t )readInteger: ( uint8_t * )data size: ( uint32_t )size;

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

- ( BOOL )open: ( NSError * _Nullable __autoreleasing * )error
{
    io_service_t smc = IOServiceGetMatchingService( kIOMainPortDefault, IOServiceMatching( "AppleSMC" ) );
    
    if( smc == IO_OBJECT_NULL )
    {
        if( error )
        {
            *( error ) = [ [ NSError alloc ] initWithTitle: @"Cannot Open SMC" message: @"Unable to retrieve the SMC service." code: -1 ];
        }
        
        return NO;
    }
    
    io_connect_t  connection = IO_OBJECT_NULL;
    kern_return_t result     = IOServiceOpen( smc, mach_task_self(), 0, &connection );
    
    if( result != kIOReturnSuccess || connection == IO_OBJECT_NULL )
    {
        if( error )
        {
            *( error ) = [ [ NSError alloc ] initWithTitle: @"Cannot Open SMC" message: @"Unable to open the SMC service." code: -1 ];
        }
        
        return NO;
    }
    
    self.connection = connection;
    
    return YES;
}

- ( BOOL )close
{
    return IOServiceClose( self.connection ) == kIOReturnSuccess;
}

- ( BOOL )callSMCFunction: ( uint32_t )function input: ( const SMCParamStruct * )input output: ( SMCParamStruct * )output
{
    size_t        inputSize  = sizeof( SMCParamStruct );
    size_t        outputSize = sizeof( SMCParamStruct );
    kern_return_t result     = IOConnectCallMethod( self.connection, kSMCUserClientOpen, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL );
    
    if( result != kIOReturnSuccess )
    {
        return NO;
    }
    
    result = IOConnectCallStructMethod( self.connection, function, input, inputSize, output, &outputSize );
    
    IOConnectCallMethod( self.connection, kSMCUserClientClose, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL );
    
    return result == kIOReturnSuccess;
}

- ( BOOL )readSMCKeyInfo: ( SMCKeyInfoData * )info forKey: ( uint32_t )key
{
    if( info == NULL || key == 0 )
    {
        return NO;
    }
    
    SMCParamStruct input;
    SMCParamStruct output;
    
    bzero( &input, sizeof( SMCParamStruct ) );
    bzero( &output, sizeof( SMCParamStruct ) );
    
    input.data8 = kSMCGetKeyInfo;
    input.key   = key;
    
    if( [ self callSMCFunction: kSMCHandleYPCEvent input: &input output: &output ] == NO )
    {
        return NO;
    }
    
    if( output.result != kSMCSuccess )
    {
        return NO;
    }
    
    *( info ) = output.keyInfo;
    
    return YES;
}

- ( BOOL )readSMCKey: ( uint32_t * )key atIndex: ( uint32_t )index
{
    if( key == NULL )
    {
        return NO;
    }
    
    SMCParamStruct input;
    SMCParamStruct output;
    
    bzero( &input, sizeof( SMCParamStruct ) );
    bzero( &output, sizeof( SMCParamStruct ) );
    
    input.data8  = kSMCGetKeyFromIndex;
    input.data32 = index;
    
    if( [ self callSMCFunction: kSMCHandleYPCEvent input: &input output: &output ] == NO )
    {
        return NO;
    }
    
    if( output.result != kSMCSuccess )
    {
        return NO;
    }
    
    *( key ) = output.key;
    
    return YES;
}

- ( BOOL )readSMCKey: ( uint32_t )key buffer: ( uint8_t * )buffer maxSize: ( uint32_t * )maxSize keyInfo: ( SMCKeyInfoData * _Nullable )keyInfo
{
    if( key == 0 || buffer == NULL || maxSize == NULL )
    {
        return NO;
    }
    
    SMCKeyInfoData info;
    
    if( [ self readSMCKeyInfo: &info forKey: key ] == NO )
    {
        return NO;
    }
    
    SMCParamStruct input;
    SMCParamStruct output;
    
    bzero( &input, sizeof( SMCParamStruct ) );
    bzero( &output, sizeof( SMCParamStruct ) );
    
    input.key              = key;
    input.data8            = kSMCReadKey;
    input.keyInfo.dataSize = info.dataSize;
    
    if( [ self callSMCFunction: kSMCHandleYPCEvent input: &input output: &output ] == NO )
    {
        return NO;
    }
    
    if( output.result != kSMCSuccess )
    {
        return NO;
    }
    
    if( *( maxSize ) < info.dataSize )
    {
        return NO;
    }
    
    if( keyInfo != NULL )
    {
        *( keyInfo ) = info;
    }
    
    *( maxSize ) = info.dataSize;
    
    bzero( buffer, *( maxSize ) );
    
    for( uint32_t i = 0; i < info.dataSize; i++ )
    {
        if( key == kSMCKeyACID )
        {
            buffer[ i ] = output.bytes[ i ];
        }
        else
        {
            buffer[ i ] = output.bytes[ info.dataSize - ( i + 1 ) ];
        }
    }
    
    return YES;
}

- ( uint32_t )readSMCKeyCount
{
    uint8_t  data[ 8 ];
    uint32_t size = sizeof( data );
    
    bzero( data, size );
    
    if( [ self readSMCKey: kSMCKeyNKEY buffer: data maxSize: &size keyInfo: NULL ] == NO )
    {
        return 0;
    }
    
    return [ self readInteger: data size: size ];
}

- ( uint32_t )readInteger: ( uint8_t * )data size: ( uint32_t )size
{
    uint32_t n = 0;
    
    if( size > sizeof( uint32_t ) )
    {
        return 0;
    }
    
    for( uint32_t i = 0; i < size; i++ )
    {
        n |= ( uint32_t )( data[ i ] ) << ( i * 8 );
    }
    
    return n;
}

- ( void )readAllKeys: ( void ( ^ )( NSArray< SMCData * > * ) )completion
{
    dispatch_async
    (
        self.queue,
        ^( void )
        {
            uint32_t count                      = [ self readSMCKeyCount ];
            NSMutableArray< SMCData * > * items = [ [ NSMutableArray alloc ] initWithCapacity: count ];
            
            for( uint32_t i = 0; i < count; i++ )
            {
                uint32_t key;
                
                if( [ self readSMCKey: &key atIndex: i ] == NO )
                {
                    continue;
                }
                
                SMCKeyInfoData info;
                uint8_t        data[ 32 ];
                uint32_t       size = sizeof( data );
                
                if( [ self readSMCKey: key buffer: data maxSize: &size keyInfo: &info ] == NO )
                {
                    continue;
                }
                
                SMCData * item = [ [ SMCData alloc ] initWithKey: key type: info.dataType data: [ NSData dataWithBytes: data length: size ] ];
                
                [ items addObject: item ];
            }
            
            completion( items );
        }
    );
}

@end
