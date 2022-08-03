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

@objc class SMCData: NSObject
{
    @objc( SMCDataType )
    public enum DataType: Int
    {
        case Test
    }
    
    @objc public dynamic var key:   String
    @objc public dynamic var type:  DataType
    @objc public dynamic var value: Any?
    @objc public dynamic var data:  Data
    
    @objc public convenience init( key: String, type: DataType, data: Data )
    {
        let value = SMCData.valueForData( data, type: type )
        
        self.init( key: key, type: type, value: value, data: data )
    }
    
    @objc public init( key: String, type: DataType, value: Any?, data: Data )
    {
        self.key   = key
        self.type  = type
        self.value = value
        self.data  = data
    }
    
    private class func valueForData( _ data: Data, type: DataType ) -> Any?
    {
        42
    }
    
    override func isEqual( _ object: Any? ) -> Bool
    {
        self.isEqual( to: object )
    }
    
    override func isEqual( to object: Any? ) -> Bool
    {
        guard let data = object as? SMCData else
        {
            return false
        }
        
        return self.key == data.key
    }
}
