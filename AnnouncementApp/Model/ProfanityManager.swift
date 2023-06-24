//
//  ProfanityManager.swift
//  IA3V2
//
//  Created by James Nunn on 11/6/2023.
//

import Foundation

class BadWordClass {
    var words = [String]()
    init() {
        loadCSV()
    }
    func loadCSV(){
        var wordsArray = [String]()
        guard let filePath = Bundle.main.path(forResource: "GoogleList", ofType: "csv") else{
            print("Error: File not found.")
            self.words = []
            return
        }
        var CSVAsString = ""
        do{
            CSVAsString = try String(contentsOfFile: filePath)
        } catch{
            print(error)
            self.words = []
            return
        }
        let csvRows = CSVAsString.components(separatedBy: [",", "\n"])
        for row in csvRows {
            let rowColumns = row.components(separatedBy: ",")
            wordsArray.append(contentsOf: rowColumns)
        }
        self.words = wordsArray
    }
}
