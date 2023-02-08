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
import UniformTypeIdentifiers

class MainWindowController: NSWindowController, NSTableViewDataSource, NSTableViewDelegate
{
    @IBOutlet private var dataController: NSArrayController!
    @IBOutlet private var tableView:      NSTableView!

    @objc private dynamic var data       = [ SMCData ]()
    @objc private dynamic var refreshing = false
    @objc private dynamic var regex      = false
    {
        didSet
        {
            self.updateFilterPredicate()
        }
    }

    @objc private dynamic var searchText = ""
    {
        didSet
        {
            self.updateFilterPredicate()
        }
    }

    override var windowNibName: NSNib.Name?
    {
        "MainWindowController"
    }

    override func windowDidLoad()
    {
        super.windowDidLoad()

        self.dataController.sortDescriptors =
            [
                NSSortDescriptor( key: "keyName", ascending: true, selector: #selector( NSString.localizedCaseInsensitiveCompare( _: ) ) ),
            ]

        self.refresh( nil )
        self.tableView.setDraggingSourceOperationMask( .copy, forLocal: false )
    }

    private func updateFilterPredicate()
    {
        if self.searchText.isEmpty
        {
            self.dataController.filterPredicate = nil
        }
        else if self.regex, let regex = try? NSRegularExpression( pattern: self.searchText )
        {
            self.dataController.filterPredicate = NSPredicate
            {
                o, _ in guard let data = o as? SMCData
                else
                {
                    return false
                }

                if let _ = regex.matches( in: data.keyName,  range: NSMakeRange( 0, data.keyName.count ) ).first
                {
                    return true
                }

                if let _ = regex.matches( in: data.typeName, range: NSMakeRange( 0, data.typeName.count ) ).first
                {
                    return true
                }

                return false
            }
        }
        else
        {
            self.dataController.filterPredicate = NSPredicate( format: "keyName contains[c] %@ || typeName contains[c] %@", self.searchText, self.searchText )
        }
    }

    @IBAction
    public func toggleRegex( _ sender: Any? )
    {
        self.regex = self.regex == false

        if let item = sender as? NSMenuItem
        {
            item.state = self.regex ? .on : .off
        }
    }

    @IBAction
    public func saveDocument( _ sender: Any? )
    {
        self.export( sender )
    }

    @IBAction
    public func refresh( _ sender: Any? )
    {
        let responder = self.window?.firstResponder

        if responder == self.tableView
        {
            self.window?.makeFirstResponder( nil )
        }

        self.refreshing = true

        DispatchQueue.global( qos: .userInitiated ).async
        {
            let data = SMC.shared.readAllKeys()

            DispatchQueue.main.async
            {
                self.data       = data
                self.refreshing = false

                if responder == self.tableView
                {
                    self.window?.makeFirstResponder( responder )
                }
            }
        }
    }

    @IBAction
    public func export( _ sender: Any? )
    {
        guard let window = self.window
        else
        {
            NSSound.beep()

            return
        }

        let panel                  = NSSavePanel()
        panel.canCreateDirectories = true
        panel.allowsOtherFileTypes = false
        panel.allowedContentTypes  = [ .plainText ]
        panel.nameFieldStringValue = "SMC"

        panel.beginSheetModal( for: window )
        {
            guard let url = panel.url, $0 == .OK
            else
            {
                return
            }

            do
            {
                try self.export( to: url )
            }
            catch
            {
                NSAlert( error: error ).runModal()
            }
        }
    }

    private func export( to url: URL ) throws
    {
        guard let items  = self.dataController.content as? [ SMCData ]
        else
        {
            throw SMCHelper.error( title: "Cannot Export Items", message: "Cannot retrieve items to export.", code: 0 )
        }

        let lines: [ String ] = items.compactMap { $0.description }

        guard let data = lines.joined( separator: "\n" ).data( using: .utf8 )
        else
        {
            throw SMCHelper.error( title: "Cannot Export Items", message: "Cannot create UTF-8 data from text.", code: 0 )
        }

        try data.write( to: url )
    }

    @IBAction
    public func copy( _ sender: Any? )
    {
        guard let items = self.dataController.selectedObjects as? [ SMCData ], items.isEmpty == false
        else
        {
            NSSound.beep()

            return
        }

        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects( items )
    }

    func tableView( _ tableView: NSTableView, pasteboardWriterForRow row: Int ) -> NSPasteboardWriting?
    {
        guard let arranged = self.dataController.arrangedObjects as? [ SMCData ], row < arranged.count
        else
        {
            return nil
        }

        return arranged[ row ]
    }
}
