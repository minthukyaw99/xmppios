//
//  SettingsViewController.swift
//  OneChat
//
//  Created by Paul on 19/02/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

import UIKit
import XMPPFramework
import xmpp_messenger_ios

class SettingsViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
  
  @IBOutlet var usernameTextField: UITextField!
  @IBOutlet var passwordTextField: UITextField!
  @IBOutlet var validateButton: UIButton!
  
    @IBOutlet var avater: UIImageView!
  
    let imagePicker = UIImagePickerController()
  // Mark: Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    imagePicker.delegate = self
    let tap = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
    view.addGestureRecognizer(tap)
	
	if OneChat.sharedInstance.isConnected() {
		usernameTextField.hidden = true
		passwordTextField.hidden = true
		validateButton.setTitle("Disconnect", forState: UIControlState.Normal)
	} else {
		if NSUserDefaults.standardUserDefaults().stringForKey(kXMPP.myJID) != "kXMPPmyJID" {
			usernameTextField.text = NSUserDefaults.standardUserDefaults().stringForKey(kXMPP.myJID)
			passwordTextField.text = NSUserDefaults.standardUserDefaults().stringForKey(kXMPP.myPassword)
		}
	}
  }
  
  // Mark: Private Methods
  
  func DismissKeyboard() {
    if usernameTextField.isFirstResponder() {
      usernameTextField.resignFirstResponder()
    } else if passwordTextField.isFirstResponder() {
      passwordTextField.resignFirstResponder()
    }
  }
  
  // Mark: IBAction
  
  @IBAction func validate(sender: AnyObject) {
	if OneChat.sharedInstance.isConnected() {
		OneChat.sharedInstance.disconnect()
		usernameTextField.hidden = false
		passwordTextField.hidden = false
		validateButton.setTitle("Validate", forState: UIControlState.Normal)
	} else {
		OneChat.sharedInstance.connect(username: self.usernameTextField.text!, password: self.passwordTextField.text!) { (stream, error) -> Void in
			if let _ = error {
				let alertController = UIAlertController(title: "Sorry", message: "An error occured: \(error)", preferredStyle: UIAlertControllerStyle.Alert)
				alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
					//do something
				}))
				self.presentViewController(alertController, animated: true, completion: nil)
			} else {
				self.dismissViewControllerAnimated(true, completion: nil)
			}
		}
	}
  }
  
    @IBAction func changeAvatar(sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
  @IBAction func close(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
    
    //Mark: UIImagePickerControllerDelegage
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            avater.contentMode = .ScaleAspectFit
            avater.image = pickedImage
            
            let iq = DDXMLElement.elementWithName("iq") as! DDXMLElement
            iq.addAttributeWithName("from", stringValue: kXMPP.myJID)
            iq.addAttributeWithName("type", stringValue: "set")
            iq.addAttributeWithName("id", stringValue: "vc1")

            let vCard = DDXMLElement.elementWithName("vCard") as! DDXMLElement
            vCard.addAttributeWithName("xmlns", stringValue:"vcard-temp")
            
            let photo = DDXMLElement.elementWithName("PHOTO") as! DDXMLElement
            let type = DDXMLElement.elementWithName("type", stringValue: "image/jpg") as! DDXMLElement
            
            let image64 = UIImageJPEGRepresentation(pickedImage,0.5)
            let imageData = image64!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
            
            let binval = DDXMLElement.elementWithName("BINVAL", stringValue: imageData) as! DDXMLElement
            photo.addChild(type)
            photo.addChild(binval)
            vCard.addChild(photo)
            iq.addChild(vCard)
            
            print(vCard)
            
            OneChat.sharedInstance.xmppStream?.sendElement(iq)
           
            
            
            
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
  
  // Mark: UITextField Delegates
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if passwordTextField.isFirstResponder() {
      textField.resignFirstResponder()
      validate(self)
    } else {
      textField.resignFirstResponder()
    }
    
    return true
  }
  
  // Mark: Memory Management
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
