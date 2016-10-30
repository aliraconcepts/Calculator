//
//  ViewController.swift
//  Calculator
//
//  Created by sashka on 18/09/2016.
//  Copyright © 2016 sashka. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var display: UILabel! // instance
    
    @IBOutlet weak var displayStack: UILabel! // Displays stack numbers
    
    
    var userIsInTheMiddleOfTypingNumbers = false
    
    var brain = CalculatorBrain()
    
    // Calculator Digits
    @IBAction func appendDigit(_ sender: UIButton) {   // method
        let digit = sender.currentTitle!
        if !userIsInTheMiddleOfTypingNumbers {display.text = "0"} // initialise label for new entry
        
        if !(display!.text!.contains(".")) || !(digit == ".") {
            if userIsInTheMiddleOfTypingNumbers || digit == "." {
                display.text = display.text! + digit
            }
            else
            {
                display.text = digit
            }
            userIsInTheMiddleOfTypingNumbers = true
        }
    }
    
    // Add variable to stack
    
    @IBAction func appendVariable(_ sender: UIButton) {
        let variableName = sender.currentTitle!
        if userIsInTheMiddleOfTypingNumbers {
            enterKey()
        }
        if let result = brain.pushOperand(symbol: variableName) {
            displayValue = result
        }
        else {
            displayValue = nil
        }
        displayStack.text = brain.description
    }
    
    // Sets the current dsiplay value to variable 'M'
    
    @IBAction func setVariable(_ sender: UIButton) {
        brain.variableValues["M"] = displayValue!
        userIsInTheMiddleOfTypingNumbers = false
        displayStack.text = brain.description
        displayValue = brain.evalute()
    }
    
    // Clears Stack and Variables
    
    @IBAction func clearAll() {
        brain.clearStack()
        displayValue = nil
        displayStack.text = brain.description
        brain.variableValues.removeAll()
    }
    
    // Operation Keys
    @IBAction func operate(_ sender: UIButton) {
        let operation = sender.currentTitle!
        if userIsInTheMiddleOfTypingNumbers {
            enterKey()
        }
        if let result = brain.performOperation(symbol: operation) {
            displayValue = result
        }
        else {
            displayValue = nil
        }
        displayStack.text = brain.description
    }
    
    // Enter Key
    @IBAction func enterKey() {
        if let result = brain.pushOperand(operand: displayValue!) {
            displayValue = result
        }
        else {
            displayValue = nil
        }
        displayStack.text = brain.description
    }
    
    // Getter and Setter of string and double values for display label
    var displayValue: Double? {
        get {
            if let newNumber = NumberFormatter().number(from: display.text!) as? Double {
                return newNumber
            }
            return nil
        }
        set {
            display.text = "\(newValue ?? 0)"
            userIsInTheMiddleOfTypingNumbers = false
        }
    }
}

