//
//  LoginVM.swift
//  swifty-proteins
//
//  Created by XPI-9 on 17/9/2026.
//

import SwiftUI
import Combine

struct LoginVMody: Codable {
    let WS_API_REF_ID : String
    let WS_API_REQ_ID : String
}


class LoginVM : ObservableObject {
    
    @Published var error: String? = nil
    @Published var success : String? = nil
    @Published var isLoading: Bool = false
    
    func load() {
        DispatchQueue.main.async {
            self.error = nil
            self.success = nil
            self.isLoading = true
        }
        
        let daysOffVMBody = DaysOffVMBody(
            WS_API_REF_ID: "l31YleIi9/jaLFEZESVjq/f7ALAmD4vWiGyRx47c7pc=",
            WS_API_REQ_ID: AppConfig.getCurrentDateTime()
        )
        
        NetworkManager.makePOSTRequest(withSession:true, url: URL(string: ServerConfig.GTX_APP)!, data: daysOffVMBody) { result in
            switch result {
                case .success(let res):
                    do {
                        if let jsonObject = try JSONSerialization.jsonObject(with: res, options: []) as? [String: Any] {
                            print("DaysOffVM response : \(jsonObject)")
                            if let errorCode = jsonObject["ERROR"] as? String {
                                if errorCode == "000" {
                                    
                                    var daysOff : [DaysOff] = []
                                    if let holidaysArray = jsonObject["holidaysArray"] as? [[String: Any]] {
                                        for dayOff in holidaysArray {
                                            
                                            let holidayDate = self.stringToDate(dayOff["holidayDate"] as? String ?? "")
                                            
                                            if let holidayDate = holidayDate, self.isDateInThisWeekOrFuture(date: holidayDate) {
                                                daysOff.append(
                                                    DaysOff (
                                                        Control: dayOff["Control"] as? String ?? "",
                                                        description: dayOff["description"] as? String ?? "",
                                                        holidayDate: holidayDate,
                                                        id: dayOff["id"] as? String ?? ""
                                                    )
                                                )
                                            }
                                        }
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.isLoading = false
                                        self.success = daysOff
                                    }
                                }
                                else {
                                    if let errorDesc = jsonObject["ERROR_DESC"] as? String {
                                        DispatchQueue.main.async {
                                            self.isLoading = false
                                            self.error = "\(errorDesc)"
                                        }
                                    } else {
                                        DispatchQueue.main.async {
                                            self.isLoading = false
                                            self.error = "Something went wrong, please try again"
                                        }
                                    }
                                }
                            }  else {
                               DispatchQueue.main.async {
                                   self.isLoading = false
                                   self.error = "Something went wrong, please try again"
                               }
                           }
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.error = "\(error.localizedDescription)"
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.error = "\(error.localizedDescription)"
                    }
            }
        }
    }
    
    func isDateInThisWeekOrFuture(date: Date, weekStartsOn: Int = 2) -> Bool {
        var calendar = Calendar.current
           calendar.firstWeekday = weekStartsOn
           
           guard let startOfThisWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start,
                 let startOfLastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: startOfThisWeek)
           else { return false }
           
           return date >= startOfLastWeek
    }
    
    func stringToDate(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        
        return formatter.date(from: string)
    }
}
