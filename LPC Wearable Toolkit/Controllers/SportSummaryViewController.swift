//
//  SportSummaryViewController.swift
//  LPC Wearable Toolkit
//
//  Created by Development on 9/3/18.
//  Copyright © 2018 Varun Narayanswamy LPC. All rights reserved.
//

import UIKit

class SportSummaryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var actionPicker: UIPickerView!
    @IBOutlet weak var trainButton: UIButton!
    @IBOutlet weak var testButton: UIButton!
    @IBOutlet weak var reviewButton: UIButton!
    
    var numberVideos = 0
    var numberSegments = 0
    var accelerationPoints = 0
    
    var sport = Sport()
    var actionStore = Actions()
    var videoStore = Videos()
    var segmentStore = Segments()
    var accelerationStore = Accelerations()
    var selectedAction: Action!
    var managedActions: [Action] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.actionPicker.delegate = self
        self.actionPicker.dataSource = self
        print(sport.name ?? "none")
        self.title = sport.name
        prepareSummary()
        managedActions = actionStore.fetch(sport: sport.name!)
        trainButton.isEnabled = false
        testButton.isEnabled = false
        reviewButton.isEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func addNewAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Add New Action", message: "Enter the name of your action", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            print("Alert storing \(textField?.text ?? "(none)"), \(self.sport.name!)")
            self.actionStore.save(name: (textField?.text!)!, sport: self.sport)
            self.managedActions = self.actionStore.fetch(sport: self.sport.name!)
            print("Count of actions: \(self.managedActions.count)")
            print("parent: \(self.managedActions[0].parentSport?.name ?? "")")
            self.actionPicker.reloadAllComponents()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "train") {
            let navigationViewController = segue.destination as! UINavigationController
            let destinationViewController = navigationViewController.viewControllers[0] as! SegmentationViewController
            print("Sport name: \(sport.name ?? "no value provided")")
            destinationViewController.sport = self.sport.name!
            destinationViewController.action = self.selectedAction.name!
        } else if (segue.identifier == "test") {
            let navigationViewController = segue.destination as! UINavigationController
            let destinationViewController = navigationViewController.viewControllers[0] as! ClassificationViewController
            print("Sport name: \(sport.name ?? "no value provided")")
            destinationViewController.sport = self.sport.name!
            destinationViewController.action = self.selectedAction.name!
        } else if (segue.identifier == "review") {
            // you didn't connect the segment yet
            let navigationViewController = segue.destination as! UINavigationController
            let destinationViewController = navigationViewController.viewControllers[0] as! SegmentReviewViewController
            print("Sport name: \(sport.name ?? "no value provided")")
            destinationViewController.sport = self.sport.name!
            destinationViewController.action = self.selectedAction.name!
        }
    }
    
    // MARK: Picker View functions
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.managedActions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.managedActions[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedAction = actionStore.managedActions[row]
        trainButton.isEnabled = true
        trainButton.backgroundColor = UIColor(red: 69/255.0, green: 255/255.0, blue: 190/255.0, alpha: 1.0)
        //45FFBE
        if (numberSegments > 0) && (accelerationPoints > 0) {
            testButton.isEnabled = true
            testButton.backgroundColor = UIColor(red: 69/255.0, green: 255/255.0, blue: 190/255.0, alpha: 1.0)
            reviewButton.isEnabled = true
            reviewButton.backgroundColor = UIColor(red: 69/255.0, green: 255/255.0, blue: 190/255.0, alpha: 1.0)
        }
    }
    
    func prepareSummary() {
        self.summaryLabel.text? = ""
        self.summaryLabel.text?.append("Description: \(sport.notes ?? "(none)")\n")
        numberVideos = videoStore.countAll(sport: sport.name!)
        self.summaryLabel.text?.append("Videos: \(numberVideos)\n")
        numberSegments = segmentStore.countAll(sport: sport.name!)
        self.summaryLabel.text?.append("Training segments: \(numberSegments)\n")
        accelerationPoints = accelerationStore.countAll(sport: sport.name!)
        self.summaryLabel.text?.append("Total Acceleration Data Points: \(accelerationPoints)\n")
    }
}

extension SportSummaryViewController {
    @IBAction func cancelToSportSummaryViewController(_ segue: UIStoryboardSegue) {
        prepareSummary()
    }
}

