
import Foundation

// Group ID
let groupID = "group.com.awal.tasktodo"


// Functions getTask, AddTask, DeleteAll and deleteTask ( UserDefault )
func getTaskArray() -> [String]{
    let defaults = UserDefaults(suiteName: groupID)
    let myArray = defaults?.stringArray(forKey: "TaskToday") ?? [String]()
    return myArray
}

func addTaskToday(task: String) -> Bool {
    let defaults = UserDefaults(suiteName: groupID)
    var myArray = getTaskArray()
    myArray.append(task)
    defaults?.set(myArray, forKey: "TaskToday")
    return true
}


func deleteAll() -> Bool{
    let defaults = UserDefaults(suiteName: groupID)
    var myArray = getTaskArray()
    myArray.removeAll()
    defaults?.set(myArray, forKey: "TaskToday")
    return true
}

func deleteTaskToday(task: String) -> Bool {
    let defaults = UserDefaults(suiteName: groupID)
    var myArray = getTaskArray()
    for index in 0 ..< myArray.count{
        if (myArray[index] == task){
            myArray.remove(at: index)
            defaults?.set(myArray, forKey: "TaskToday")
            return true
        }
    }
    return false
}
