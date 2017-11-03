//
//  MainView.swift
//  CurrencyX
//
//  Created by Ty Nguyen on 10/18/17.
//  Copyright © 2017 Team 5. All rights reserved.
//

import UIKit

struct currency : Codable
{
    var symbol : String
    var price : Float
    var bid : Float
    var ask : Float
    var timestamp : Int
    init()
    {
        symbol = ""
        price = 0.0
        bid = 0.0
        ask = 0.0
        timestamp = 0
    }
}


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
    var total_supply : String
    var percent_change_1h: String
    var percent_change_24h : String
    var percent_change_7d : String
    var last_updated : String
    init (ID : String, Name : String, Symbol : String, Rank: String, Price_USD: String, Price_BTC: String, Volume_USD: String,
          Market_cap : String, Available_Supply: String, Total_Supply: String, Percent_1h: String, Percent_24h: String, Percent_7d: String, LastUpdated : String){
        id = ID;
        name = Name
        symbol = Symbol
        rank = Rank
        price_usd = Price_USD
        price_btc = Price_BTC
        volume_usd = Volume_USD
        market_cap_usd = Market_cap
        available_supply = Available_Supply
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
//class RegCurrs: Codable {
//    let regCurrs: [regCurrency]
//
//    init(regCurrs: [regCurrency]) {
//        self.regCurrs = regCurrs
//    }
//}
//
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
//     var cryptArrFin = [worldCoinIndex]()        // JSON data for crypto currencies, access format:
    
    var selectedCryptCell = CryptoCurrency()
    var crypCurrencyList = [CryptoCurrency]()
    
    //Currencies variable
    var Currencies = [currency]()

    
    var backgroundImage = UIImage()
    var backgroundImageView = UIImageView()
    var backgroundImageName = ""
    
    @IBOutlet weak var cryptTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "MainView"
        
        backgroundImageName = "Background4.png"
        setBackgroundImage()
        getData()//get crypto data
        getCurrency()//get currency data
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
    
    //get crypto function
    func getData(){
        var url = URL(string: "https://api.coinmarketcap.com/v1/ticker/?limit=10")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if (error == nil && data != nil) {
                do{
                    let json : NSArray = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                    for i in 0..<json.count {
                        let value : Dictionary = json.object(at: i) as! Dictionary<String,String>
                        var cryptpInfo = CryptoCurrency(ID: value["id"]!, Name: value["name"]!, Symbol: value["symbol"]!, Rank: value["rank"]!, Price_USD : value["price_usd"]!, Price_BTC: value["price_btc"]!, Volume_USD: value["24h_volume_usd"]!, Market_cap: value["market_cap_usd"]!, Available_Supply: value["available_supply"]!, Total_Supply: value["total_supply"]!, Percent_1h: value["percent_change_1h"]!, Percent_24h: value["percent_change_24h"]!, Percent_7d: value["percent_change_7d"]!, LastUpdated: value["last_updated"]!)
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
    //get currency function
    func getCurrency() {
        let url = URL (string: "https://forex.1forge.com/1.0.2/quotes?&api_key=hz3FMVzCV5cSCQmbvXRvoDuKIWk8f26B")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if let data = data {
                do {
                    //convert to json
                    let jsonDecoder = JSONDecoder()
                    let currList = try jsonDecoder.decode([currency].self, from: data)
                    self.Currencies = currList
                    DispatchQueue.main.async {
                        self.cryptTableView.reloadData()
                        print("JSON downloaded")
                      //  print(currList)
                    }
                } catch {
                    print("Can't pull JSON")
                }
                
            } else if let error = error {
                print(error.localizedDescription)
            }
            
        }
        task.resume()
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cell = cryptTableView

        if(cell?.tag == 1)
        {
           // print(crypCurrencyList.count + Currencies.count)

            return crypCurrencyList.count //+ Currencies.count)
        }
        else
        {
            return Currencies.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let prototypeCell = cryptTableView
        if (indexPath.row < crypCurrencyList.count)
        {
            let cell = cryptTableView .dequeueReusableCell(withIdentifier: "cryptCell", for: indexPath)
            let currLbl = cell.viewWithTag(1) as! UILabel
            let priceLbl = cell.viewWithTag(2) as! UILabel
            
            currLbl.text = crypCurrencyList[indexPath.row].symbol
            priceLbl.text = crypCurrencyList[indexPath.row].price_usd
            
            return cell

        }
        else
        {
            let cell1 = cryptTableView .dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath)

            let firstlbl = cell1.viewWithTag(5) as! UILabel
            let currencyLbl = cell1.viewWithTag(6) as! UILabel
            let priceLabel = cell1.viewWithTag(7) as! UILabel

            firstlbl.text = String(Currencies[indexPath.row].symbol.characters.prefix(3))
            currencyLbl.text = String(Currencies[indexPath.row].symbol.characters.suffix(3))
            priceLabel.text = String(Currencies[indexPath.row].price)

            return cell1
        }
    
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
//    func loadJson() {
//        print("Loading JSON")
//        let url = URL(string: "https://www.worldcoinindex.com/apiservice/json?key=wECsN7y9YetLXQJNwwMQKJFPI")
//        guard let downloadURL = url else {return}
//
//        //get JSON data
//        URLSession.shared.dataTask(with: downloadURL) { data, urlResponse, error in
//            guard let data = data, error == nil, urlResponse != nil else {
//                print("JSON fail")
//                return
//            }
//            print("JSON downloaded")    //error check for success
//
//            do {
//                let decoder = JSONDecoder()
//                let crypt = try decoder.decode(cryptoCurr.self, from: data)       //decode JSON data
//                print(crypt.Markets[0].Label)
//
//                DispatchQueue.main.async{
//                    self.cryptTableView.reloadData()
//                }
//
//                //self.cryptArrFin = [crypt]
//                //print(self.cryptArrFin[0].Markets[1].Label)
//                self.cryptArrFin = crypt.Markets
//                print(self.cryptArrFin[1].Label)
//                print(self.cryptArrFin.count)
//
//
//            } catch {
//                print("failed to decode JSON")
//            }
//            }.resume()
//
//
//    }
  
   

}
