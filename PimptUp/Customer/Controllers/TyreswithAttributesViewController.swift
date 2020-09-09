//
//  TyreswithAttributesViewController.swift
//  PimptUp
//
//  Created by JanAhmad on 06/04/2020.
//  Copyright © 2020 jinnbyte. All rights reserved.
//

import UIKit
import Alamofire

class TyreswithAttributesViewController: UIViewController {

    @IBOutlet weak var tyresListTV: UITableView!

    @IBOutlet weak var addTyreBtn: UIButton!
    @IBOutlet weak var viewDealer: UIButton!
    
    var userTypeId: Int?
    var defaults  = UserDefaults.standard
    var userId: Int?
    
    var tyresList: [TyresList] = []
    var getIds: [Int]?
    var dealerTyresList: [DealerTyresList] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        print(getIds)
        if (userTypeId == 2){
        addTyreBtn.layer.cornerRadius = addTyreBtn.frame.height/5
               addTyreBtn.clipsToBounds = true
        }
        userTypeId = defaults.integer(forKey: "UserTypeId")
        userId = defaults.integer(forKey: "UserId")
        
        if (userTypeId == 3){
       tyresListTV.delegate = self
        let param: [String:Int] = ["ManufacturerId":getIds![0],"TyreRangeId":getIds![1],"TyreSizeId":getIds![2],"TyreWidthId":getIds![3],"TyreAspectRatioId":getIds![4]]
        
        APIRequests.getTyresWithAttributes(parameters: param, completion: APIRequestForGetTyresWithAttributes)
        }
        else{
            addTyreBtn.isHidden = true
            APIRequests.getTyresOfDealer(id: userId!, completion: APIRequestForGetTyresWithAttributes)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
         APIRequests.getTyresOfDealer(id: userId!, completion: APIRequestForGetTyresWithAttributes)
    }
    
    @IBAction func addTyreButton(_ sender: Any) {
        
    }
    
    fileprivate func APIRequestForGetTyresWithAttributes(response:Any?,error:Error?){
        
        if APIResponse.isValidResponse(viewController: self, response: response, error: error){
            
            
            
            //    let data = try! JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
            let decoder = JSONDecoder()
            do {
                print("testing break point")
//                let data = try JSONSerialization.data(withJSONObject: response, options: .fragmentsAllowed)
                let data = try JSONSerialization.data(withJSONObject: response!, options: .prettyPrinted)
                               print(data)
                               print(data,"Printing the data here.")

                
                if (userTypeId == 3){
                let tyres = try decoder.decode(GetTyresWithAttributesResponse.self, from: data)
                tyresList = tyres.TyreList
                print(tyresList)
                }
                else{
                    let tyres = try decoder.decode(DealerTyresModelResponse.self, from: data)
                    dealerTyresList = tyres.TyresModels
                    if (dealerTyresList.count == 0){
                        tyresListTV.isHidden = true
                        addTyreBtn.isHidden = false
                    }
                    print(dealerTyresList)
                }
                self.tyresListTV.reloadData()
                
            } catch {
                
                print("error trying to convert data to JSON")
                Constants.Alert(title: "Error", message: Constants.statusMessage , controller: self)
            }
            
        }
        else{
            
            Constants.Alert(title: "Login Error", message: "Sorry no record found", controller: self)
        }
    }

}
extension TyreswithAttributesViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(userTypeId == 3)
        {
        return tyresList.count
        }
        else{
            return dealerTyresList.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TyresList") as! TyresWithAttributesTableViewCell
        if(userTypeId == 3){
        cell.cellObj = tyresList[indexPath.row]
        cell.setData()
        }
        else{
            cell.cellObjDealer = dealerTyresList[indexPath.row]
            cell.setDataDealer()
            cell.delegate = self
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
}

extension TyreswithAttributesViewController: TyreDetailProtocol{
    func onClickViewDetail(tyreObj: DealerTyresList) {
        print("delegate request \(tyreObj.Name) is calling ")
        let vc = UIStoryboard.init(name: "Dealer", bundle: Bundle.main).instantiateViewController(withIdentifier: "TyreDetail") as? TyreDetailViewController
        vc!.tyreObjDealer = tyreObj
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
}