//
//  ViewController.swift
//  MemeFirstVersion
//
//  Created by Administrator on 24.01.21.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var cameraButton: UIBarButtonItem!
    
    @IBOutlet var topTextField: UITextField!
    @IBOutlet var bottomTextField: UITextField!
        
    @IBOutlet var shareButton: UIBarButtonItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
    
    @IBOutlet var topToolBar: UIToolbar!
    @IBOutlet var bottomToolBar: UIToolbar!
    
    let topTextFieldDelegate = TopTextFieldDelegate()
    let bottomTextFieldDelegate = BottomTextFieldDelegate()
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 25)!,
        NSAttributedString.Key.strokeWidth:  NSNumber(value: 0.4)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setInitialValues()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func setInitialValues()
    {
        topTextField.text = ""
        topTextField.placeholder = "TOP"
        topTextField.textAlignment = NSTextAlignment.center
        topTextField.defaultTextAttributes = memeTextAttributes
        
        bottomTextField.text = ""
        bottomTextField.placeholder = "BOTTOM"
        bottomTextField.textAlignment = NSTextAlignment.center
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        imageView.image = nil
        
        topTextField.delegate = topTextFieldDelegate
        bottomTextField.delegate = bottomTextFieldDelegate
        
        shareButton.isEnabled = false
    }
    
    func subscribeToKeyboardNotifications() {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: bottomTextField)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: bottomTextField)
    }
    
    func unsubscribeFromKeyboardNotifications() {

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: bottomTextField)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: bottomTextField)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {

        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {

        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any)
    {
        let pickerController = UIImagePickerController()
        
        pickerController.delegate = self
        
        pickerController.sourceType = .photoLibrary
        
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            pickerController.sourceType = UIImagePickerController.SourceType.camera
        }
        else
        {
            pickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        }
        
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any)
    {
        let pickerController = UIImagePickerController()
        
        pickerController.delegate = self
        
        pickerController.sourceType = .camera
        
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func share(_ sender: Any)
    {
        let image = generateMemedImage()
        
        let shareActivityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        present(shareActivityController, animated: true, completion: nil)
        
        shareActivityController.completionWithItemsHandler = {
            
            (activityType: UIActivity.ActivityType?, completed:
            Bool, arrayReturnedItems: [Any]?, error: Error?) in
            
            if (completed)
            {
                self.save()
            }
            
        }
    }
    
    @IBAction func cancel(_ sender: Any)
    {
        setInitialValues()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            imageView.image = image
            shareButton.isEnabled = true
            
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    // save the meme
    func save() {
        // Create the meme
        let _ = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: generateMemedImage())
    }

    func generateMemedImage() -> UIImage {

        topToolBar.isHidden = true
        bottomToolBar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        topToolBar.isHidden = false
        bottomToolBar.isHidden = false

        return memedImage
    }
    
    struct Meme {
        
        var topText: String
        var bottomText: String
        var originalImage: UIImage
        var memedImage: UIImage
    }
    
}

