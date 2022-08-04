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

import Foundation

extension Data
{
    var sint8: Int8
    {
        Int8( bitPattern: self.uint8 )
    }
    
    var sint16: Int16
    {
        Int16( bitPattern: self.uint16 )
    }
    
    var sint32: Int32
    {
        Int32( bitPattern: self.uint32 )
    }
    
    var sint64: Int64
    {
        Int64( bitPattern: self.uint64 )
    }
    
    var uint8: UInt8
    {
        UInt8( self[ 0 ] )
    }
    
    var uint16: UInt16
    {
        let u1 = UInt16( self[ 0 ] ) << 8
        let u2 = UInt16( self[ 1 ] ) << 0
        
        return u1 | u2
    }
    
    var uint32: UInt32
    {
        let u1 = UInt32( self[ 0 ] ) << 24
        let u2 = UInt32( self[ 1 ] ) << 16
        let u3 = UInt32( self[ 2 ] ) <<  8
        let u4 = UInt32( self[ 3 ] ) <<  0
        
        return u1 | u2 | u3 | u4
    }
    
    var uint64: UInt64
    {
        let u1 = UInt64( self[ 0 ] ) << 56
        let u2 = UInt64( self[ 1 ] ) << 48
        let u3 = UInt64( self[ 2 ] ) << 40
        let u4 = UInt64( self[ 3 ] ) << 32
        let u5 = UInt64( self[ 4 ] ) << 24
        let u6 = UInt64( self[ 5 ] ) << 16
        let u7 = UInt64( self[ 6 ] ) <<  8
        let u8 = UInt64( self[ 7 ] ) <<  0
        
        return u1 | u2 | u3 | u4 | u5 | u6 | u7 | u8
    }
    
    var float32: Float32
    {
        Float32( bitPattern: self.uint32 )
    }
    
    var float64: Float64
    {
        Float64( bitPattern: self.uint64 )
    }
}
