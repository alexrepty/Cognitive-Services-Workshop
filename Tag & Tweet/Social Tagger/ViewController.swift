//
//  ViewController.swift
//  Social Tagger
//
//  Created by Alexander Repty on 16.05.16.
//  Copyright © 2016 maks apps. All rights reserved.
//

import UIKit
import Social

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Properties
    
    var image: UIImage? = nil
    var categories: [String]? = nil
    
    // MARK: IBOutlets
    
    @IBOutlet weak var stepOneButton: UIButton!
    @IBOutlet weak var stepTwoButton: UIButton!
    @IBOutlet weak var stepThreeButton: UIButton!
    
    @IBOutlet weak var stepOneLabel: UILabel!
    @IBOutlet weak var stepTwoLabel: UILabel!
    @IBOutlet weak var stepThreeLabel: UILabel!
    
    @IBOutlet weak var stepOneSpinner: UIActivityIndicatorView!
    @IBOutlet weak var stepTwoSpinner: UIActivityIndicatorView!
    @IBOutlet weak var stepThreeSpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var serviceSelectionControl: UISegmentedControl!
    
    // MARK: IBActions
    
    @IBAction func chooseImage(sender: AnyObject) {
        self.image = nil
        self.categories = nil
        
        self.validateCurrentStep()
        
        self.stepOneLabel.text = ""
        self.stepTwoLabel.text = ""
        self.stepThreeLabel.text = ""
        self.stepOneSpinner.startAnimating()
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = false
        imagePickerController.delegate = self
        imagePickerController.sourceType = .PhotoLibrary
        
        self.presentViewController(
            imagePickerController,
            animated: true,
            completion: nil
        )
    }
    
    @IBAction func categoriseImage(sender: AnyObject) {
        self.categories = nil
        
        self.validateCurrentStep()
        
        self.stepTwoLabel.text = ""
        self.stepTwoSpinner.startAnimating()
        
        let manager = CognitiveServicesManager()
        manager.retrievePlausibleTagsForImage(self.image!) { (result, error) -> (Void) in
            dispatch_async(dispatch_get_main_queue(), { 
                self.stepTwoSpinner.stopAnimating()
                
                if let _ = error {
                    self.stepTwoLabel.text = "😱"
                    return
                }
                
                self.categories = result
                self.validateCurrentStep()
            })
        }
    }
    
    @IBAction func shareImage(sender: AnyObject) {
        self.stepThreeLabel.text = ""
        self.stepThreeSpinner.startAnimating()
        
        let serviceType = self.serviceSelectionControl.selectedSegmentIndex == 0 ? SLServiceTypeTwitter : SLServiceTypeFacebook
        let composeViewController = SLComposeViewController(forServiceType: serviceType)
        composeViewController.addImage(self.image!)
        
        var string = ""
        for category in self.categories! {
            if string.characters.count > 0 {
                string += " "
            }
            
            string += "#\(category)"
        }
        composeViewController.setInitialText(string)
        composeViewController.completionHandler = { (result) in
            self.stepThreeSpinner.stopAnimating()
            
            switch result {
            case .Cancelled:
                self.stepThreeLabel.text = "🙁"
            case .Done:
                self.stepThreeLabel.text = "😃"
            }
        }
        
        self.presentViewController(
            composeViewController,
            animated: true,
            completion: nil
        )
    }
    
    // MARK: Private Methods
    
    private func validateCurrentStep() {
        self.stepOneSpinner.stopAnimating()
        self.stepTwoSpinner.stopAnimating()
        self.stepThreeSpinner.stopAnimating()

        if let _ = self.image {
            // We have selected an image, update our status accordingly and enable the next step's button.
            self.stepOneLabel.text = "😃"
            self.stepTwoButton.enabled = true
        } else {
            self.stepTwoLabel.text = ""
            self.stepThreeLabel.text = ""
            self.stepTwoButton.enabled = false
            self.stepThreeButton.enabled = false
        }
        
        if let _ = self.categories {
            // We have received a list of categories, update our status accordingly and enable the next step's button.
            self.stepTwoLabel.text = "😃"
            self.stepThreeButton.enabled = true
        } else {
            self.stepThreeLabel.text = ""
            self.stepThreeButton.enabled = false
        }
    }
    
    // MARK: UIImagePickerControllerDelegate Methods
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        self.stepOneLabel.text = "🙁"
        self.validateCurrentStep()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        if let image = info[UIImagePickerControllerOriginalImage] as! UIImage? {
            self.image = image
        } else {
            self.stepOneLabel.text = "😱"
        }
        
        self.validateCurrentStep()
    }
}
