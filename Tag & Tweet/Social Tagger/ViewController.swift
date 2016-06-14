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
    
    @IBAction func chooseImage(_ sender: AnyObject) {
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
        imagePickerController.sourceType = .photoLibrary
        
        self.present(
            imagePickerController,
            animated: true,
            completion: nil
        )
    }
    
    @IBAction func categoriseImage(_ sender: AnyObject) {
        self.categories = nil
        
        self.validateCurrentStep()
        
        self.stepTwoLabel.text = ""
        self.stepTwoSpinner.startAnimating()
        
        let manager = CognitiveServicesManager()
        manager.retrievePlausibleTagsForImage(self.image!) { (result, error) -> (Void) in
            DispatchQueue.main.async(execute: { 
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
    
    @IBAction func shareImage(_ sender: AnyObject) {
        self.stepThreeLabel.text = ""
        self.stepThreeSpinner.startAnimating()
        
        let serviceType = self.serviceSelectionControl.selectedSegmentIndex == 0 ? SLServiceTypeTwitter : SLServiceTypeFacebook
        let composeViewController = SLComposeViewController(forServiceType: serviceType)
        composeViewController?.add(self.image!)
        
        var string = ""
        for category in self.categories! {
            if string.characters.count > 0 {
                string += " "
            }
            
            string += "#\(category)"
        }
        composeViewController?.setInitialText(string)
        composeViewController?.completionHandler = { (result) in
            self.stepThreeSpinner.stopAnimating()
            
            switch result {
            case .cancelled:
                self.stepThreeLabel.text = "🙁"
            case .done:
                self.stepThreeLabel.text = "😃"
            }
        }
        
        self.present(
            composeViewController!,
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
            self.stepTwoButton.isEnabled = true
        } else {
            self.stepTwoLabel.text = ""
            self.stepThreeLabel.text = ""
            self.stepTwoButton.isEnabled = false
            self.stepThreeButton.isEnabled = false
        }
        
        if let _ = self.categories {
            // We have received a list of categories, update our status accordingly and enable the next step's button.
            self.stepTwoLabel.text = "😃"
            self.stepThreeButton.isEnabled = true
        } else {
            self.stepThreeLabel.text = ""
            self.stepThreeButton.isEnabled = false
        }
    }
    
    // MARK: UIImagePickerControllerDelegate Methods
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
        self.stepOneLabel.text = "🙁"
        self.validateCurrentStep()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerControllerOriginalImage] as! UIImage? {
            self.image = image
        } else {
            self.stepOneLabel.text = "😱"
        }
        
        self.validateCurrentStep()
    }
}
