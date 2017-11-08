//
//  MainView.swift
//  CurrencyX
//
//  Created by Ty Nguyen on 10/18/17.
//  Copyright © 2017 Team 5. All rights reserved.
//

import UIKit

class worldCoinIndex : Codable {
    var Label: String
    var Name: String
    var Price_btc: Float
    var Price_usd: Float
    var Price_cny: Float
    var Price_eur: Float
    var Price_gbp: Float
    var Price_rur: Float
    var Volume_24h: Float
    var Timestamp: Int
    init(){
        Label = ""
        Name = ""
        Price_btc = 0.0
        Price_usd = 0.0
        Price_cny = 0.0
        Price_eur = 0.0
        Price_gbp = 0.0
        Price_rur = 0.0
        Volume_24h = 0.0
        Timestamp = 0
    }
}

class CryptoCurrency{
    var id : String
    var name : String
    var symbol : String
    var rank : String
    var price_usd: String
    var price_btc : String
    var volume_usd : String
    var market_cap_usd : String
    var available_supply : String
    var max_supply : String
    var total_supply : String
    var percent_change_1h: String
    var percent_change_24h : String
    var percent_change_7d : String
    var last_updated : String
    init (ID : String, Name : String, Symbol : String, Rank: String, Price_USD: String, Price_BTC: String, Volume_USD: String,
          Market_cap : String, Available_Supply: String, Total_Supply: String, Max_Supply : String, Percent_1h: String, Percent_24h: String, Percent_7d: String, LastUpdated : String){
        id = ID;
        name = Name
        symbol = Symbol
        rank = Rank
        price_usd = Price_USD
        price_btc = Price_BTC
        volume_usd = Volume_USD
        market_cap_usd = Market_cap
        available_supply = Available_Supply
        max_supply = Max_Supply
        total_supply = Total_Supply
        percent_change_1h = Percent_1h
        percent_change_24h = Percent_24h
        percent_change_7d = Percent_7d
        last_updated = LastUpdated
    }
    init(){
        id = ""
        name = ""
        symbol = ""
        rank = ""
        price_usd = ""
        price_btc = ""
        volume_usd = ""
        market_cap_usd = ""
        available_supply = ""
        total_supply = ""
        max_supply = ""
        percent_change_1h = ""
        percent_change_24h = ""
        percent_change_7d = ""
        last_updated = ""
    }
}
class cryptoCurr : Codable {
    let Markets: [worldCoinIndex]
    
    init(Markets: [worldCoinIndex]){
        self.Markets = Markets
    }
}

//for XML data
class RegCurrs: Codable {
    let regCurrs: [regCurrency]
    
    init(regCurrs: [regCurrency]) {
        self.regCurrs = regCurrs
    }
}

class regCurrency: Codable {
    let Symbol: String
    let Bid: Float
    let Ask: Float
    let High: Float
    let Low: Float
    let Direction: Float
    let Last: String
    
    init(Symbol: String, Bid: Float, Ask: Float, High: Float, Low: Float, Direction: Float, Last: String) {
        self.Symbol = Symbol
        self.Bid = Bid
        self.Ask = Ask
        self.High = High
        self.Low = Low
        self.Direction = Direction
        self.Last = Last
    }
}

class MainView: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //http://rates.fxcm.com/RatesXML
    //http://api.fixer.io/latest
    //https://www.worldcoinindex.com/apiservice/json?key=wECsN7y9YetLXQJNwwMQKJFPI
     var cryptArrFin = [worldCoinIndex]()        // JSON data for crypto currencies, access format:
    
    var selectedCryptCell = CryptoCurrency()
    var crypCurrencyList = [CryptoCurrency]()
    
    var backgroundImage = UIImage()
    var backgroundImageView = UIImageView()
    var backgroundImageName = ""
    
    @IBOutlet weak var cryptTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "MainView"
        
        backgroundImageName = "Background4.png"
        setBackgroundImage()
        getData()
        
        cryptTableView.delegate = self
        cryptTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setBackgroundImage() {
        if backgroundImageName > "" {
            backgroundImageView.removeFromSuperview()
            backgroundImage = UIImage(named: backgroundImageName)!
            backgroundImageView = UIImageView(frame: self.view.bounds)
            backgroundImageView.image = backgroundImage
            self.view.addSubview(backgroundImageView)
            self.view.sendSubview(toBack: backgroundImageView)
        }
    }
    
    // detect device orientation changes
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if UIDevice.current.orientation.isLandscape {
            print("rotated device to landscape")
            setBackgroundImage()
        } else {
            print("rotated device to portrait")
            setBackgroundImage()
        }
    }
    
    func getData(){
        var available_supply : String = ""
        var total_supply : String = ""
        var max_supply : String = ""
        var url = URL(string: "https://api.coinmarketcap.com/v1/ticker/?limit=10")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if (error == nil && data != nil) {
                do{
                    let json : NSArray = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                    for i in 0..<json.count {
                        let value : Dictionary = json.object(at: i) as! Dictionary<String,AnyObject>
                        var ret_value = self.nullToNil(value: value["available_supply"] as? AnyObject)
                        if ret_value == nil { available_supply = "0"}
                        else{ available_supply = value["available_supply"]! as! String}
                        ret_value = self.nullToNil(value: value["total_supply"] as? AnyObject)
                        if ret_value == nil { total_supply = "0"}
                        else{ total_supply = value["total_supply"]! as! String}
                        ret_value = self.nullToNil(value: value["max_supply"] as? AnyObject)
                        if ret_value == nil { max_supply = "0"}
                        else{ total_supply = value["max_supply"]! as! String}
                        
                        var cryptpInfo = CryptoCurrency(ID: value["id"]! as! String, Name: value["name"]! as! String, Symbol: value["symbol"]! as! String, Rank: value["rank"]! as! String, Price_USD : value["price_usd"]! as! String, Price_BTC: value["price_btc"]! as! String, Volume_USD: value["24h_volume_usd"]! as! String, Market_cap: value["market_cap_usd"]! as! String, Available_Supply: available_supply, Total_Supply: total_supply, Max_Supply : max_supply, Percent_1h: value["percent_change_1h"]! as! String, Percent_24h: value["percent_change_24h"]! as! String, Percent_7d: value["percent_change_7d"]! as! String, LastUpdated: value["last_updated"]! as! String)
                        self.crypCurrencyList.append(cryptpInfo)
                    }
                    DispatchQueue.main.async {
                        self.cryptTableView.reloadData()
                    }
                }
                catch{
                    print(error)
                }
            }
            else{
                print(error)
            }
        }
        task.resume()
    }
    func nullToNil(value : AnyObject?) -> AnyObject?{
        if value is NSNull {
            return nil
        }
        else{
            return value
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return cryptArrFin.count
        return crypCurrencyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCell(withIdentifier: "cryptCell", for: indexPath) as! MainViewTableViewCell
        
        let currLbl = cell.viewWithTag(1) as! UILabel
        let priceLbl = cell.viewWithTag(2) as! UILabel
        
        currLbl.text = crypCurrencyList[indexPath.row].symbol
        priceLbl.text = crypCurrencyList[indexPath.row].price_usd
        
        return cell
        
   /*     //cell.currencyLabelLbl.text = cryptArrFin[indexPath.row].Label
        var temp = cryptArrFin[indexPath.row].Label
        
        let index = temp.index(of: "/") ?? temp.endIndex
        let temp2 = String(temp[..<index])
        var temp1 = String(temp.characters.prefix(3))
        cell.currencyLabelLbl.text = temp2
        cell.currencyPriceLbl.text = "$\(cryptArrFin[indexPath.row].Price_usd)"
        return cell*/
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //      selectedCryptCell = cryptArrFin[indexPath.row]
        selectedCryptCell = crypCurrencyList[indexPath.row]
        self.performSegue(withIdentifier: "MainToDetail", sender: self)
    }
    
    @IBAction func sendBtn(_ sender: Any) {
        performSegue(withIdentifier: "MainToWallet", sender: self)
    }
    
    @IBAction func NotificationSetting(_ sender: Any) {
        performSegue(withIdentifier: "MainToAcc", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MainToDetail" {
            let dvc = segue.destination as! DetailView
            //        dvc.cryptCurrency = selectedCryptCell
        }
    }
    
    
    
 // We don't need this part anymore
    func loadJson() {
        print("Loading JSON")
        let url = URL(string: "https://www.worldcoinindex.com/apiservice/json?key=wECsN7y9YetLXQJNwwMQKJFPI")
        guard let downloadURL = url else {return}
        
        //get JSON data
        URLSession.shared.dataTask(with: downloadURL) { data, urlResponse, error in
            guard let data = data, error == nil, urlResponse != nil else {
                print("JSON fail")
                return
            }
            print("JSON downloaded")    //error check for success
            
            do {
                let decoder = JSONDecoder()
                let crypt = try decoder.decode(cryptoCurr.self, from: data)       //decode JSON data
                print(crypt.Markets[0].Label)
                
                DispatchQueue.main.async{
                    self.cryptTableView.reloadData()
                }
                
                //self.cryptArrFin = [crypt]
                //print(self.cryptArrFin[0].Markets[1].Label)
                self.cryptArrFin = crypt.Markets
                print(self.cryptArrFin[1].Label)
                print(self.cryptArrFin.count)
                
                
            } catch {
                print("failed to decode JSON")
            }
            }.resume()
        
        // updateTable()
        
    }
    
    func loadXML(){
        print("Loading XML")
        let url = URL(string: "http://rates.fxcm.com/RatesXML")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
