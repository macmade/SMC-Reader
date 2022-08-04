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

@objc class SMCData: NSObject, NSPasteboardWriting
{
    @objc public dynamic var key:  UInt32
    @objc public dynamic var type: UInt32
    @objc public dynamic var data: Data
    
    @objc public var keyName:  String
    {
        String( fourCC: self.key )
    }
    
    @objc public var typeName: String
    {
        String( fourCC: self.type )
    }
    
    @objc public init( key: UInt32, type: UInt32, data: Data )
    {
        self.key  = key
        self.type = type
        self.data = data
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
    
    func writableTypes( for pasteboard: NSPasteboard ) -> [ NSPasteboard.PasteboardType ]
    {
        [ .string ]
    }
    
    func pasteboardPropertyList( forType type: NSPasteboard.PasteboardType ) -> Any?
    {
        self.description
    }
    
    override var description: String
    {
        let data  = DataTransformer().transformedValue( self.data ) as? String ?? ""
        let value = SMCValueTransformer().transformedValue( self )  as? String ?? ""
        
        return "\( self.keyName )\t\( self.typeName )\t\( value )\t\( data )"
    }
}
