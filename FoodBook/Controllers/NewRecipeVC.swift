//
//  newRecipeCV.swift
//  FoodBook
//
//  Created by Jacob Ahlberg on 2017-09-15.
//  Copyright © 2017 Jacob Ahlberg. All rights reserved.
//

import UIKit

class NewRecipeVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var minuteLbl: UILabel!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var titleLbl: FloatLabelTextView!
    @IBOutlet weak var ingredientsLbl: FloatLabelTextView!
    @IBOutlet weak var informationLbl: FloatLabelTextView!
    @IBOutlet weak var instructionLbl: FloatLabelTextView!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var recipeImageView: UIImageView!
    
    var pickerValue: String = String(CATEGORIES[0].title)
    var picker: UIImagePickerController? = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.categoryPicker.dataSource = self
        self.categoryPicker.delegate = self
        titleLbl.textContainer.maximumNumberOfLines = 1;
    }

    // Changes the label value on how long time the the recipe will take to make
    @IBAction func minuteSliderValueChanged(sender: UISlider) {
        let value: Int = Int(sender.value)
        minuteLbl.text = String("\(value) minuter")
    }
    
    // Set maximum characters in  title label
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count // for Swift use count(newText)
        return numberOfChars <= 40
    }
    
    // Saves data to firebase and alerts the user with an alert message
    @IBAction func saveBtnPressed(_ sender: Any) {
        let newImage: UIImage = recipeImageView.image!
        let time = Int(timeSlider.value)
        let category = pickerValue
        let information = informationLbl.text ?? ""
        guard let titleName = titleLbl.text, !titleName.isEmpty else {
            alertWindow(title: "Opps!", message: "Du måste fylla i titel", buttonMessage: "Okej, jag fixar det!")
            return
        }
        guard let ingredients = ingredientsLbl.text, !ingredients.isEmpty else {
            alertWindow(title: "Opps!", message: "Du måste fylla i ingredienser!", buttonMessage: "Okej, jag fixar det!")
            return
        }
        guard let instructions = instructionLbl.text, !instructions.isEmpty else {
            alertWindow(title: "Opps!", message: "Du måste fylla i utförande!", buttonMessage: "Okej, jag fixar det!")
            return
        }
        
        let saveRecipe: Recipe = Recipe(recipeName: titleName, recipeTime: time, recipeInformation: information, ingredients: ingredients, instructions: instructions, category: category, imageURL: "", key: "")
        
        DataService.instance.upLoadNewRecipe(recipe: saveRecipe, image: newImage)
        alertWindow(title: "Nytt Recept", message: "Nytt recept har lagts till!", buttonMessage: "Schysst!")
        
    }
    
    // Alert function
    func alertWindow(title: String, message: String, buttonMessage: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: buttonMessage, style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}

// Picker
extension NewRecipeVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Shows the number of rows in the picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return CATEGORIES.count
    }
    
    // Shows the title for the corresponding row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return CATEGORIES[row].title
    }
    
    // Sets the pickerValue as the current active value in the picker
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerValue = String(CATEGORIES[row].title)
    }
}

// Camera and library extension
extension NewRecipeVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // Activates camera when camera is pressed
    @IBAction func takePhotoBtnPressed(_ sender: Any) {
        picker?.delegate = self
        picker?.sourceType = .camera
        present(picker!, animated: true, completion: nil)
    }
    
    // Activates library when "library" is pressed
    @IBAction func photoLibraryBtnPressed(_ sender: Any) {
        picker?.delegate = self
        picker?.sourceType = .photoLibrary
        picker?.allowsEditing = true
        self.present(picker!, animated: true, completion: nil)
    }
    
    // Saves the chosen image from either camera or library to UIImage
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        recipeImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
}

