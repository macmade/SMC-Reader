/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2023, Jean-David Gadina - www.xs-labs.com
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

import Cocoa
import SMCKit

@objc
public extension SMCData
{
    override func isEqual( _ object: Any? ) -> Bool
    {
        self.isEqual( to: object )
    }

    override func isEqual( to object: Any? ) -> Bool
    {
        guard let data = object as? SMCData
        else
        {
            return false
        }

        return self.key == data.key
    }

    var dataSize: Int
    {
        self.data.count
    }

    var hexData: String
    {
        self.data.map { String( format: "%02X", $0 ) }.joined( separator: "" )
    }

    var stringValue: String
    {
        if self.typeName == "flag", let flag = self.value as? Bool
        {
            return flag ? "True" : "False"
        }

        if let value = self.value
        {
            return String( describing: value )
        }

        return ""
    }
}

@objc
extension SMCData: NSPasteboardWriting
{
    public func writableTypes( for pasteboard: NSPasteboard ) -> [ NSPasteboard.PasteboardType ]
    {
        [ .string ]
    }

    public func pasteboardPropertyList( forType type: NSPasteboard.PasteboardType ) -> Any?
    {
        "\( self.keyName )\t\( self.stringValue )\t\( self.typeName )\t\( self.dataSize )\t\( self.hexData )"
    }
}
