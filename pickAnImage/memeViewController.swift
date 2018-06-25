//
//  ViewController.swift
//  pickAnImage
//
//  Created by Seth Paxton on 6/11/18.
//  Copyright © 2018 Seth Paxton. All rights reserved.
//

import UIKit

class memeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextBox: UITextField!
    @IBOutlet weak var bottomTextBox: UITextField!
    @IBOutlet weak var topNavBar: UINavigationBar!
    @IBOutlet weak var bottomButtonBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialView()
    }

    
    // MARK: initialView
    // Setup the initial view and clear an existing editing
    func initialView() {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        shareButton.isEnabled = false

        // Top Text Field
        setTextFields(textField: topTextBox, fieldName: "Top Field")
        
        // Bottom Text Field
        setTextFields(textField: bottomTextBox, fieldName: "Bottom Field")
        
        // Clear background
        imageView.image = nil
    }
    
    func setTextFields(textField: UITextField, fieldName: String) {
        // Text modifiers
        let memeTextAttributes:[String: Any] = [
            NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
            NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedStringKey.strokeWidth.rawValue: -2.5]
        
        textField.defaultTextAttributes = memeTextAttributes
        textField.delegate = self
        textField.text = ""
        textField.textAlignment = .center
        textField.placeholder = fieldName
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        subscribeToKeyboardNotificationsHide()
        
        // Enable the share button if an image is selected. 
        if imageView.image != nil {
            shareButton.isEnabled = true
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        unsubscribeFromKeyboardNotificationsHide()
    }
    
    // MARK: pickAnImage
    func pickAnImage(source: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        present(imagePicker, animated: true, completion: nil)
    }
    
    // Button used to pick an image from the existing album
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        pickAnImage(source: .photoLibrary)
    }

    // Take an image from the camera
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pickAnImage(source: .camera)
    }
    
    // Set the background based on image picked
    internal func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any])
    {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = chosenImage
        dismiss(animated:true, completion: nil)
        
    }
    
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
    
    // Move keyboard when editing text
    @objc func keyboardWillShow(_ notification:Notification) {
        // Do not move the keyboard if editing the top text field
        if bottomTextBox.isEditing {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
        
    }
    
    // Get the height of the keyboard for editing adjustments
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }
    
    func subscribeToKeyboardNotificationsHide() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotificationsHide() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    // Save the current image as a meme and return custom type
    func save() -> UIImage {
        // Create the meme
        let memedImage = generateMemedImage()
        let meme = Meme(topText: topTextBox.text!, bottomText: bottomTextBox.text!, originalImage: imageView.image!, memedImage: memedImage)

        return meme.memedImage
    }
    
    // Activity view to share image
    @IBAction func shareImage(_ sender: Any) {
            
        // image to share
        let image = generateMemedImage()

        // set up activity view controller
        let imageToShare = [ image ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.completionWithItemsHandler = {
            (activityType, completed, items, error) in
            
            guard completed else { print("User cancelled."); return }
            
            _ = self.save()
            
            print("Completed With Activity Type: \(String(describing: activityType))")
        }
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    // If the cancel button is selected, reset the view to default
    @IBAction func resetView(_ sender: Any) {
        self.initialView()
        print("reset view" )
    }
    
    // Helper to generate the actual meme image
    func generateMemedImage() -> UIImage {
        
        self.topNavBar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.topNavBar.isHidden = false
        
        return memedImage
    }
}

