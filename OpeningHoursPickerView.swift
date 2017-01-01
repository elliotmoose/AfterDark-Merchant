//
//  OpeningHoursPickerView.swift
//  AfterDark Merchant
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 17/12/16.
//  Copyright © 2016 Kohbroco. All rights reserved.
//

import UIKit

protocol OpeningHoursPickerDelegate : class {
    func DatePickerValueChanged(output : String)
}

class OpeningHoursPickerView: UIPickerView,UIPickerViewDelegate,UIPickerViewDataSource {

    var openingHoursDelegate : OpeningHoursPickerDelegate?
    
    var currentOutput = "closed"
    var openingHoursString = "6pm"
    var closingHoursString = "12am"
    var closedOutput = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.delegate = self
        self.reloadAllComponents()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            //open, close, closed
            return 3
        //hours
        case 1:
            if closedOutput
            {
                return 0
            }
            else
            {
                let numberOfHours = 12
                return numberOfHours
            }
        //mins
        case 2:
            if closedOutput
            {
                return 0
            }
            else
            {
                let numberOfMinutes = 60/5
                return numberOfMinutes
            }
        //am/pm
        case 3:
            return 2
            
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        //updates the other componenets when first changes -> (either when choose close or open change to respective time)

        
        if component == 0
        {
            if row == 0
            {
                currentOutput = "closed"
                self.openingHoursDelegate?.DatePickerValueChanged(output: currentOutput)
                closedOutput = true
                reloadAllComponents()

                return
            }
            else
            {
                //update display
                closedOutput = false
                UpdateDisplayForSelectedTime()
                reloadAllComponents()

            }
            
        }
        else
        {
            //change current output
            //if open hours
            if pickerView.selectedRow(inComponent: 0) == 1
            {
                let hourString = String(format: "%d", pickerView.selectedRow(inComponent: 1) + 1)
                
                
                var minString = String(format: "%02d", pickerView.selectedRow(inComponent: 2)*5)
                if minString == "00"
                {
                    minString = ""
                }
                var ampmString = ""
                if pickerView.selectedRow(inComponent: 3) == 0
                {
                    ampmString = "am"
                }
                else
                {
                    ampmString = "pm"
                }
                
                openingHoursString = "\(hourString)\(minString)\(ampmString)"
            }
            else //if closing hours
            {
                let hourString = String(format: "%d", pickerView.selectedRow(inComponent: 1) + 1)
                var minString = String(format: "%02d", pickerView.selectedRow(inComponent: 2)*5)
                if minString == "00"
                {
                    minString = ""
                }
                var ampmString = ""
                if pickerView.selectedRow(inComponent: 3) == 0
                {
                    ampmString = "am"
                }
                else
                {
                    ampmString = "pm"
                }
                
                closingHoursString = "\(hourString)\(minString)\(ampmString)"
            }

            
            
        
        }
        
        
        
        
        
        //callback
        currentOutput = "\(openingHoursString)-\(closingHoursString)"
        self.openingHoursDelegate?.DatePickerValueChanged(output: currentOutput)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch component {
        case 0: //open,close,closed
            switch row {
            case 0:
                return "closed"
            case 1:
                return "opening"
            case 2:
                return "closing"
            default:
                return ""
            }
            
        case 1: //hour
            
            //if its closed
            if pickerView.selectedRow(inComponent: 0) == 0
            {
                return ""
            }
            else
            {
                return String(format: "%d", row + 1)
            }
            

        case 2: //mins
            if pickerView.selectedRow(inComponent: 0) == 0
            {
                return ""
            }
            else
            {
                return String(format: "%02d", row*5)
            }
        case 3:
            if pickerView.selectedRow(inComponent: 0) == 0
            {
                return ""
            }
            else
            {
                if row == 0
                {
                    return "am"
                }
                else
                {
                    return "pm"
                }
            }
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        
        let openCloseComponentWidth = Sizing.ScreenWidth()/3
        let amPmComponentWidth : CGFloat = 100
        let hoursComponentWidth = (Sizing.ScreenWidth() - openCloseComponentWidth - amPmComponentWidth)/2
        
        switch component {
        case 0:
            return openCloseComponentWidth
        case 1:
            return hoursComponentWidth
        case 2:
            return hoursComponentWidth
        case 3:
            return amPmComponentWidth
            
        default:
            return 0
        }
    }
    
    func LoadFromString(input : String) //view will appear
    {
        //split string to get timing
        closedOutput = true
        guard input != "" else {return}
        
        if input != "closed"
        {
            //turns input into opening and closing (e.g 6pm and 5am)
            let stringArray = input.components(separatedBy: "-")
            
            //safety
            guard stringArray.count > 1 else {print("ERROR: time doesnt have - separator");return}
            
            let openingHoursString = stringArray[0]
            let closingHoursString = stringArray[1]
            
            //safety check
            guard openingHoursString != "" else {print("ERROR: no opening hour given");return}
            guard closingHoursString != "" else {print("ERROR: no closing hour given");return}

            //sets own pickerview string for future use
            self.openingHoursString = openingHoursString
            self.closingHoursString = closingHoursString
            
            
            //set to "edit opening hours" mode
            self.selectRow(1, inComponent: 0, animated: false)
            closedOutput = false
            UpdateDisplayForSelectedTime()
        }
        else
        {
            self.selectRow(0, inComponent: 0, animated: false)
            closedOutput = true
            reloadAllComponents()
            self.selectRow(0, inComponent: 1, animated: false)
            self.selectRow(0, inComponent: 2, animated: false)
            self.selectRow(0, inComponent: 3, animated: false)
        }
        

    }
    
    func UpdateDisplayForSelectedTime() //this is based on picker view variable openinghoursstring and closinghoursstring
    {
        if self.selectedRow(inComponent: 0) == 1
        {
            guard openingHoursString != "" else {return}
            
            //removes am pm (e.g 6 and 5)
            let  openingTime = openingHoursString.substring(to: openingHoursString.index(openingHoursString.endIndex, offsetBy: -2))
            
            //splits hours and minutes
            var openingHour = -1
            var openingMin = -1
            if openingTime.characters.count > 2 //if timing includes minutes (3 is minimum for mins e.g 515pm)
            {
                // then hour will be first 1-2 characters, mins will be last 2
                openingHour = Int(openingTime.substring(to: openingTime.index(openingTime.endIndex, offsetBy: -2)))!
                openingMin = Int(openingTime.substring(from: openingTime.index(openingTime.endIndex, offsetBy: -2)))!
            }
            else
            {
                //time = hour cuz theres no mins
                openingHour = Int(openingTime)!
                openingMin = 0
            }
            
            //gets am and pm (e.g pm and am)
            let openingampm = openingHoursString.substring(with: openingHoursString.index(openingHoursString.endIndex, offsetBy: -2)..<openingHoursString.endIndex)
            
            
            
            //UPDATE DISPLAY =============================================
            reloadAllComponents()
            //hours
            self.selectRow(openingHour - 1, inComponent: 1, animated: false)
            
            //mins
            self.selectRow(openingMin, inComponent: 2, animated: false)
            
            //am pm
            if openingampm == "am"
            {
                self.selectRow(0, inComponent: 3, animated: false)
            }
            else
            {
                self.selectRow(1, inComponent: 3, animated: false)
            }

        }
        else if self.selectedRow(inComponent: 0) == 2
        {
            guard closingHoursString != "" else {return}
            
            //removes am pm (e.g 6 and 5)
            let  closingTime = closingHoursString.substring(to: closingHoursString.index(closingHoursString.endIndex, offsetBy: -2))
            
            //splits hours and minutes
            var closingHour = -1
            var closingMin = -1
            if closingTime.characters.count > 2 //if timing includes minutes (3 is minimum for mins e.g 515pm)
            {
                // then hour will be first 1-2 characters, mins will be last 2
                closingHour = Int(closingTime.substring(to: closingTime.index(closingTime.endIndex, offsetBy: -2)))!
                closingMin = Int(closingTime.substring(from: closingTime.index(closingTime.endIndex, offsetBy: -2)))!
            }
            else
            {
                //time = hour cuz theres no mins
                closingHour = Int(closingTime)!
                closingMin = 0
            }
            
            //gets am and pm (e.g pm and am)
            let closingampm = closingHoursString.substring(with: closingHoursString.index(closingHoursString.endIndex, offsetBy: -2)..<closingHoursString.endIndex)
            
            
            
            //UPDATE DISPLAY =============================================
            //hours
            reloadAllComponents()
            self.selectRow(closingHour - 1, inComponent: 1, animated: false)
            
            //mins
            self.selectRow(closingMin, inComponent: 2, animated: false)
            
            //am pm
            if closingampm == "am"
            {
                self.selectRow(0, inComponent: 3, animated: false)
            }
            else
            {
                self.selectRow(1, inComponent: 3, animated: false)
            }

            
        }
    }

}
