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
import UniformTypeIdentifiers

class MainWindowController: NSWindowController
{
    @IBOutlet private var dataController: NSArrayController!
    
    private var smc  = SMC()
    private var timer: Timer?
    
    @objc private dynamic var data = [ SMCData ]()
    
    override var windowNibName: NSNib.Name?
    {
        "MainWindowController"
    }
    
    override func windowDidLoad()
    {
        super.windowDidLoad()
        
        self.dataController.sortDescriptors =
        [
            NSSortDescriptor( key: "key", ascending: true )
        ]
        
        self.timer = Timer.scheduledTimer( withTimeInterval: 1, repeats: true )
        {
            _ in self.update()
        }
        
        do
        {
            try self.smc.open()
            self.update()
        }
        catch let error
        {
            NSAlert( error: error ).runModal()
            NSApp.terminate( nil )
        }
    }
    
    private func update()
    {
        self.smc.readAllKeys
        {
            data in DispatchQueue.main.async
            {
                self.data = data
            }
        }
    }
    
    @IBAction public func export( _ sender: Any? )
    {
        guard let window = self.window else
        {
            NSSound.beep()
            
            return
        }
        
        let panel                  = NSSavePanel()
        panel.canCreateDirectories = true
        panel.allowsOtherFileTypes = false
        panel.allowedContentTypes  = [ .plainText ]
        
        panel.beginSheetModal( for: window )
        {
            guard let url = panel.url, $0 == .OK else
            {
                return
            }
            
            do
            {
                try self.export( to: url )
            }
            catch let error
            {
                NSAlert( error: error ).runModal()
            }
        }
    }
    
    private func export( to url: URL ) throws
    {
        guard let items  = self.dataController.arrangedObjects as? [ SMCData ] else
        {
            throw NSError( title: "Cannot Export Items", message: "Cannot retrieve items to export." )
        }
        
        let lines: [ String ] = items.compactMap
        {
            item in
            
            guard let type = SMCDataTypeTransformer().transformedValue( item ) as? String,
                  let data = DataTransformer().transformedValue( item.data )   as? String
            else
            {
                return nil
            }
            
            let value: String =
            {
                guard let value = item.value else
                {
                    return ""
                }
                
                return String( describing: value )
            }()
            
            return "\( item.key )\t\( type )\t\( value )\t\( data )"
        }
        
        guard let data = lines.joined( separator: "\n" ).data( using: .utf8 ) else
        {
            throw NSError( title: "Cannot Export Items", message: "Cannot create UTF-8 data from text." )
        }
        
        try data.write( to: url )
    }
}
