
import UIKit
import CoreData
import GoogleMobileAds

class homeTask: UIViewController , UITableViewDelegate, UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource,GADInterstitialDelegate {

    var tableView: UITableView = UITableView()
    var listTask:[List] = []
    var doneTask:[List] = []
    var allTask:[List] = []
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var pickerFrame = UIPickerView()
    var pickerData = ["Choose a category"]
    var alert = UIAlertController()
    var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    var firstLoad: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        let localeLan = NSLocale(localeIdentifier: "en") as Locale?
        formatter.locale = localeLan
        let result = formatter.string(from: date)
        
        self.navigationController?.navigationBar.topItem?.title = "Today,  " + result
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationItem.largeTitleDisplayMode = .automatic
            
            let attributes = [
                NSAttributedString.Key.foregroundColor : navigationBarTintColor, NSAttributedString.Key.font: font34base!,
                ]
            
            navigationController?.navigationBar.largeTitleTextAttributes = attributes
            
        } else {
            // Fallback on earlier versions
        }

        // picker data
        pickerData.append(contentsOf: categoryList)
        //picker frame
        pickerFrame = UIPickerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 216)) // CGRectMake(left, top, width, height) - left and top are like margins
        pickerFrame.tag = 555
        //set the pickers datasource and delegate
        pickerFrame.delegate = self
        pickerFrame.dataSource = self
        
        // setup table
        setupTable()
        
        // In this case, we instantiate the banner with desired ad size.
        if(admobEnable){
             bannerView = GADBannerView(adSize: kGADAdSizeBanner)
             bannerView.adUnitID = admobAdUnit
             bannerView.rootViewController = self
             //let request = GADRequest()
             //request.testDevices = [kGADSimulatorID]
             bannerView.load(GADRequest())
             addBannerViewToView(bannerView)
            interstitial.delegate = self
        }
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
        interstitial.present(fromRootViewController: self)
    }
    
    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }
    
    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
    }
    
    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }
    
    @objc func doneClick(){
        alert.textFields![1].resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetchData()
    }
    
    @IBAction func addTask(_ sender: Any) {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let result = formatter.string(from: date)

        alert = UIAlertController(title: "New Task Todo", message: nil, preferredStyle: .alert)
        alert.view.tintColor = baseColor
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Your Task ..."
            textField.textAlignment = .center
            textField.font = font16regular!
            textField.addConstraint(textField.heightAnchor.constraint(equalToConstant: 40))
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Choose Category"
            textField.textAlignment = .center
            textField.inputView = self.pickerFrame
            textField.font = font16regular!
            textField.addConstraint(textField.heightAnchor.constraint(equalToConstant: 30))

            // ToolBar
            let toolBar = UIToolbar()
            toolBar.barStyle = .default
            toolBar.isTranslucent = true
            toolBar.tintColor = baseColor
            toolBar.sizeToFit()

            // Adding Button ToolBar
            let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(homeTask.doneClick))
            let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            doneButton.setTitleTextAttributes([NSAttributedString.Key.font: font18regular!], for: .normal)
            doneButton.tintColor = baseColor
            toolBar.setItems([spaceButton, doneButton], animated: false)
            toolBar.isUserInteractionEnabled = true
            textField.inputAccessoryView = toolBar
        }

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            let descr = textField?.text
            let categ = alert?.textFields![1].text
            let task = List(context: self.context)
            task.descriptionToDo = descr
            if(categ == "Choose a category") || (categ == ""){
                task.categoryToDo = "Others"
            }else {
                task.categoryToDo = categ
            }
            task.dateToDo = result
            task.statusToDo = false
            do {
                try self.context.save()
                self.allTask.append(task)
                self.listTask.append(task)
                _ = addTaskToday(task: task.descriptionToDo!)
                self.fetchData()

            }
            catch{
                print(error)
            }

        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    func setupTable(){
        tableView = UITableView(frame: UIScreen.main.bounds, style: UITableView.Style.plain)
        tableView.delegate      =   self
        tableView.dataSource    =   self
        tableView.register(UINib(nibName: "taskCell", bundle: nil), forCellReuseIdentifier: "cellTask")
        //tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.frame.size.height = UIScreen.main.bounds.height - (self.navigationController?.navigationBar.bounds.size.height)! - 20
        if(admobEnable){
            tableView.frame.size.height = tableView.frame.size.height - 50
        }
        tableView.allowsSelection = false
        //tableView.backgroundColor = UIColor(red: 216 / 255, green: 216 / 255, blue: 216 / 255, alpha: 1.0)
        self.view.addSubview(self.tableView)
        
    }
    
    
    @objc func fetchData(){
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let dateFetch = formatter.string(from: Date())
        var records:[List] = []
        
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "List")
        
        // Add Sort Descriptor
        let sortDescriptor = NSSortDescriptor(key: "statusToDo", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Add Predicate
        let predicate = NSPredicate(format: "dateToDo = %@", dateFetch)
        fetchRequest.predicate = predicate
        
        do {
            records = try context.fetch(fetchRequest) as! [List]
            listTask.removeAll()
            doneTask.removeAll()
            allTask.removeAll()
            _ = deleteAll()
            for record in records {
                allTask.append(record)
                if(record.statusToDo == false){
                    listTask.append(record)
                    _ = addTaskToday(task: record.descriptionToDo!)
                }
                else{
                    doneTask.append(record)
                }
            }
            // setup table
            let range = NSMakeRange(0, self.tableView.numberOfSections)
            let sections = NSIndexSet(indexesIn: range)
            self.tableView.reloadSections(sections as IndexSet, with: .automatic)
        } catch {
            print(error)
        }
        
        
    }
    
    func editTask(indexTask : IndexPath){
        
        var taskSelected :List!
        if(indexTask.section == 0){
            taskSelected = self.listTask[indexTask.row]
        } else {
            taskSelected = self.doneTask[indexTask.row]
        }
        
        alert = UIAlertController(title: "Edit Task Todo", message: nil, preferredStyle: .alert)
        alert.view.tintColor = baseColor
    
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Your Task"
            textField.textAlignment = .center
            textField.text = taskSelected.descriptionToDo
            textField.font = font16regular!
            textField.addConstraint(textField.heightAnchor.constraint(equalToConstant: 40))
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Choose Category"
            textField.textAlignment = .center
            textField.text = taskSelected.categoryToDo
            textField.inputView = self.pickerFrame
            textField.font = font16regular!
            textField.addConstraint(textField.heightAnchor.constraint(equalToConstant: 20))
            
            // ToolBar
            let toolBar = UIToolbar()
            toolBar.barStyle = .default
            toolBar.isTranslucent = true
            toolBar.sizeToFit()
            toolBar.tintColor = baseColor
            
            // Adding Button ToolBar
            let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(homeTask.doneClick))
            let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            doneButton.setTitleTextAttributes([NSAttributedString.Key.font: font18regular!], for: .normal)
            doneButton.tintColor = baseColor
            toolBar.setItems([spaceButton, doneButton], animated: false)
            toolBar.isUserInteractionEnabled = true
            textField.inputAccessoryView = toolBar
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            let descr = textField?.text
            let categ = alert?.textFields![1].text
            var searchResults: [List] = []
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "List")
            do {
                searchResults = try self.context.fetch(fetchRequest) as! [List]
                for task in searchResults {
                    if task == taskSelected {
                        task.descriptionToDo = descr
                        if(indexTask.section == 0){
                            self.listTask[indexTask.row].descriptionToDo = descr
                            if(categ == "Choose a category") || (categ == ""){
                                task.categoryToDo = "Others"
                                self.listTask[indexTask.row].categoryToDo = "Others"
                            }else {
                                task.categoryToDo = categ
                                self.listTask[indexTask.row].categoryToDo = categ
                            }
                        } else {
                            self.doneTask[indexTask.row].descriptionToDo = descr
                            if(categ == "Choose a category") || (categ == ""){
                                task.categoryToDo = "Others"
                                self.doneTask[indexTask.row].categoryToDo = "Others"
                            }else {
                                task.categoryToDo = categ
                                self.doneTask[indexTask.row].categoryToDo = categ
                            }
                        }
                        
                    }
                }
            } catch {
                print("Error with request: \(error)")
            }
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            self.fetchData()
            
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }

    // MARK:- UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [listTask.count,doneTask.count][section]
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let header1 = "Task Todo (\(listTask.count))"
        let header2 = "Done (\(doneTask.count))"
        
        return [header1,header2][section]
    }
    
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var task : List!
        if(indexPath.section == 0){
           task = listTask[indexPath.row]
        } else {
           task = doneTask[indexPath.row]
        }
        let descr = task.descriptionToDo!
        let category = task.categoryToDo!
        let status = task.statusToDo
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellTask", for: indexPath) as! taskCell
        cell.category.text = category
        cell.titleTask.text = descr
        
        if(status){
            cell.statusTask.backgroundColor = doneColor
        }else{
            cell.statusTask.backgroundColor = todoColor
        }
        
        return cell
    }
    
    
    // MARK:- UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        tableView.deselectRow(at: indexPath, animated: true)
        //        if indexPath.section == 0 {
        //            let scope: FSCalendarScope = (indexPath.row == 0) ? .month : .week
        //            self.calendar.setScope(scope, animated: true)
        //        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var status : Bool!
        var task : List!
        var descr = "self.listTask[indexPath.row].descriptionToDo!"
        if(indexPath.section == 0){
            task = self.listTask[indexPath.row]
            status = listTask[indexPath.row].statusToDo
            descr = self.listTask[indexPath.row].descriptionToDo!
        }else {
           task = self.doneTask[indexPath.row]
           status = doneTask[indexPath.row].statusToDo
        }
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { (action, indexPath) in
            // code to delete the todo goes here
            self.context.delete(task)
                        do {
                            try self.context.save()
                            self.allTask.remove(at: self.allTask.index(of: task)!)
                            if(indexPath.section == 0){
                                _ = deleteTaskToday(task: descr)
                                self.listTask.remove(at: indexPath.row)
                                
                            } else {
                                self.doneTask.remove(at: indexPath.row)
                            }
                            self.fetchData()
                        }
                        catch{
                            print(error)
                        }
        }
        delete.backgroundColor = UIColor(netHex: 0xee6f57)
        
        let updateStatus = UITableViewRowAction(style: .normal, title: (status ? "Todo" : "Done")) { (action, indexPath) in
            // code to implement the status update goes here
            var searchResults: [List] = []
            let taskSelected : List!
            if(indexPath.section == 0){
                taskSelected = self.listTask[indexPath.row]
            }else {
                taskSelected = self.doneTask[indexPath.row]
            }
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "List")
            do {
                searchResults = try self.context.fetch(fetchRequest) as! [List]
                for task in searchResults {
                    if task == taskSelected {
                        if(status){
                            task.statusToDo = false
                            self.listTask.append(taskSelected)
                            self.doneTask.remove(at: self.doneTask.index(of: taskSelected)!)
                        }else {
                            task.statusToDo = true
                            self.doneTask.append(taskSelected)
                            self.listTask.remove(at: self.listTask.index(of: taskSelected)!)
                        }
                    }
                }
                self.fetchData()
            } catch {
                print("Error with request: \(error)")
            }
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
        }
        updateStatus.backgroundColor = (status ? baseColor : UIColor(netHex: 0x206a5d))
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            // code to implement the edit task goes here
            self.editTask(indexTask: indexPath)
         
        }
        edit.backgroundColor = UIColor(netHex: 0x00334e)
        
        return [delete, edit, updateStatus]
    }

    // MARK:- picker view

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        alert.textFields![1].text = pickerData[row]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


