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

import Cocoa

@objc( SMCValueTransformer )
class SMCValueTransformer: ValueTransformer
{
    override class func transformedValueClass() -> AnyClass
    {
        NSString.self
    }
    
    override class func allowsReverseTransformation() -> Bool
    {
        false
    }
    
    override func transformedValue( _ value: Any? ) -> Any?
    {
        guard let data  = value as? SMCData,
              let value = self.value( for: data.data, type: data.type ) else
        {
            return nil
        }
        
        return String( describing: value )
    }
    
    private func value( for data: Data, type: UInt32 ) -> Any?
    {
        switch String( fourCC: type )
        {
            case "si8 ": return data.sint8.byteSwapped
            case "ui8 ": return data.uint8.byteSwapped
            case "si16": return data.sint16.byteSwapped
            case "ui16": return data.uint16.byteSwapped
            case "si32": return data.sint32.byteSwapped
            case "ui32": return data.uint32.byteSwapped
            case "si64": return data.sint64.byteSwapped
            case "ui64": return data.uint64.byteSwapped
            case "flt ": return data.float32
            case "flag": return data[ 0 ] == 1 ? "True" : "False"
            
            default: return nil
        }
    }
}
