//
//  WebserviceUtil.swift
//  GO10
//
//  Created by Jirapas Chiradechwiroj on 10/30/2559 BE.
//  Copyright © 2559 Gosoft. All rights reserved.
//

import Foundation
import RichEditorView


class RichEditorUtil{
    
    
    class func  setToolbar(width: CGFloat,height:CGFloat,editor: RichEditorView) -> RichEditorToolbar{
        
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        //custom toolbar
        toolbar.options = [RichEditorOptions.Undo,
                           RichEditorOptions.Redo,
                           RichEditorOptions.Bold,
                           RichEditorOptions.Image,
                           RichEditorOptions.Link,
                           //RichEditorOptions.AlignLeft,
                           //RichEditorOptions.AlignCenter,
                           //RichEditorOptions.AlignRight,
                           //RichEditorOptions.Indent,
                           //RichEditorOptions.Outdent
    ]

        //setPlaceholderText
        editor.setPlaceholderText(" Write something ...")
        
        return toolbar
    }
    
}

//
//protocol RichEditorDelegate {
//    func richEditor(editor: RichEditorView, heightDidChange height: Int)
//    
//    func richEditor(editor: RichEditorView, contentDidChange content: String)
//    
//    func richEditorTookFocus(editor: RichEditorView)
//    
//    func richEditorLostFocus(editor: RichEditorView)
//    
//    func richEditorDidLoad(editor: RichEditorView)
//    
//    func richEditor(editor: RichEditorView, shouldInteractWithURL url: NSURL)
//    
//    func richEditor(editor: RichEditorView, handleCusßtomAction content: String)
//}
//
//extension RichEditorDelegate {
//    
//    func richEditor(editor: RichEditorView, heightDidChange height: Int) { }
//    
//    func richEditor(editor: RichEditorView, contentDidChange content: String) { }
//    
//    func richEditorTookFocus(editor: RichEditorView) { }
//    
//    func richEditorLostFocus(editor: RichEditorView) { }
//    
//    func richEditorDidLoad(editor: RichEditorView) { }
//    
//    func richEditor(editor: RichEditorView, shouldInteractWithURL url: NSURL) -> Bool { return true }
//    
//    func richEditor(editor: RichEditorView, handleCusßtomAction content: String) { }
//    
//}
//
//extension CommentViewController:RichEditorDelegate {}
//extension NewTopicViewController: RichEditorDelegate {}
//
//
//extension CommentViewController: RichEditorToolbarDelegate {
//    
//    private func randomColor() -> UIColor {
//        let colors = [
//            UIColor.redColor(),
//            UIColor.orangeColor(),
//            UIColor.yellowColor(),
//            UIColor.greenColor(),
//            UIColor.blueColor(),
//            UIColor.purpleColor()
//        ]
//        
//        let color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
//        print("richEditorToolbarChangeTextColor")
//        return color
//    }
//    
//    func richEditorToolbarChangeTextColor(toolbar: RichEditorToolbar) {
//        let color = randomColor()
//        toolbar.editor?.setTextColor(color)
//        print("richEditorToolbarChangeTextColor")
//    }
//    
//    func richEditorToolbarChangeBackgroundColor(toolbar: RichEditorToolbar) {
//        let color = randomColor()
//        toolbar.editor?.setTextBackgroundColor(color)
//        print("richEditorToolbarChangeBackgroundColor")
//    }
//    
//    func richEditorToolbarInsertImage(toolbar: RichEditorToolbar) {
//        ImagePicker.delegate = self
//        ImagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
//        ImagePicker.allowsEditing = true
//        self.presentViewController(ImagePicker, animated: true, completion: nil)
//    }
//    
//    func richEditorToolbarInsertLink(toolbar: RichEditorToolbar) {
//        // Can only add links to selected text, so make sure there is a range selection first
//        if let hasSelection = toolbar.editor?.rangeSelectionExists() where hasSelection {
//            //            let strUrl = toolbar.editor?.runJS(("document.getSelection().getRangeAt(0).toString()"))
//            toolbar.editor?.insertLink()
//        }
//    }
//}
//
//
//extension NewTopicViewController: RichEditorToolbarDelegate {
//    
//    private func randomColor() -> UIColor {
//        let colors = [
//            UIColor.redColor(),
//            UIColor.orangeColor(),
//            UIColor.yellowColor(),
//            UIColor.greenColor(),
//            UIColor.blueColor(),
//            UIColor.purpleColor()
//        ]
//        
//        let color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
//        return color
//    }
//    
//    func richEditorToolbarChangeTextColor(toolbar: RichEditorToolbar) {
//        let color = randomColor()
//        toolbar.editor?.setTextColor(color)
//    }
//    
//    func richEditorToolbarChangeBackgroundColor(toolbar: RichEditorToolbar) {
//        let color = randomColor()
//        toolbar.editor?.setTextBackgroundColor(color)
//        
//    }
//    
//    func richEditorToolbarInsertImage(toolbar: RichEditorToolbar) {
//        print("asjkhdfklasdhjdfjkhfjkasbhgjkhsgjkhgjklshjl")
//        ImagePicker.delegate = self
//        ImagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
//        ImagePicker.allowsEditing = true
//        self.presentViewController(ImagePicker, animated: true, completion: nil)
//    }
//    
//    func richEditorToolbarInsertLink(toolbar: RichEditorToolbar) {
//        // Can only add links to selected text, so make sure there is a range selection first
//        if let hasSelection = toolbar.editor?.rangeSelectionExists() where hasSelection {
//            //        let strUrl = toolbar.editor?.runJS(("document.getSelection().getRangeAt(0).toString()"))
//            toolbar.editor?.insertLink()
//        }
//    }
//}
