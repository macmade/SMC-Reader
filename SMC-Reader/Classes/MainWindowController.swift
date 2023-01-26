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

import Cocoa
import UniformTypeIdentifiers

class MainWindowController: NSWindowController, NSTableViewDataSource, NSTableViewDelegate
{
    @IBOutlet private var dataController: NSArrayController!
    @IBOutlet private var tableView:      NSTableView!

    private var smc = SMC()

    @objc private dynamic var data       = [ SMCData ]()
    @objc private dynamic var refreshing = false

    override var windowNibName: NSNib.Name?
    {
        "MainWindowController"
    }

    override func windowDidLoad()
    {
        super.windowDidLoad()

        self.dataController.sortDescriptors =
            [
                NSSortDescriptor( key: "key", ascending: true ),
            ]

        do
        {
            try self.smc.open()
            self.refresh( nil )
        }
        catch
        {
            NSAlert( error: error ).runModal()
            NSApp.terminate( nil )
        }

        self.tableView.setDraggingSourceOperationMask( .copy, forLocal: false )
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

        self.smc.readAllKeys
        {
            data in DispatchQueue.main.async
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
            throw NSError( title: "Cannot Export Items", message: "Cannot retrieve items to export." )
        }

        let lines: [ String ] = items.compactMap { $0.description }

        guard let data = lines.joined( separator: "\n" ).data( using: .utf8 )
        else
        {
            throw NSError( title: "Cannot Export Items", message: "Cannot create UTF-8 data from text." )
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
