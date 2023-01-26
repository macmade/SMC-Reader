/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2022, Jean-David Gadina - www.xs-labs.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the Software), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

import Foundation

extension String
{
    init( fourCC: UInt32 )
    {
        let c1 = UInt8( ( fourCC >> 24 ) & 0xFF )
        let c2 = UInt8( ( fourCC >> 16 ) & 0xFF )
        let c3 = UInt8( ( fourCC >>  8 ) & 0xFF )
        let c4 = UInt8( ( fourCC >>  0 ) & 0xFF )

        self.init( format: "%c%c%c%c", c1, c2, c3, c4 )
    }

    var fourCC: UInt32
    {
        let str = self.padding( toLength: 4, withPad: " ", startingAt: 0 )

        guard let c1 = str[ str.index( str.startIndex, offsetBy: 0 ) ].asciiValue,
              let c2 = str[ str.index( str.startIndex, offsetBy: 1 ) ].asciiValue,
              let c3 = str[ str.index( str.startIndex, offsetBy: 2 ) ].asciiValue,
              let c4 = str[ str.index( str.startIndex, offsetBy: 3 ) ].asciiValue
        else
        {
            return 0
        }

        let u1 = UInt32( c1 ) << 24
        let u2 = UInt32( c2 ) << 16
        let u3 = UInt32( c3 ) <<  8
        let u4 = UInt32( c4 ) <<  0

        return u1 | u2 | u3 | u4
    }
}
