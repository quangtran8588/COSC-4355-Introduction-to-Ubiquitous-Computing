//
//  SellView.swift
//  CurrencyX
//
//  Created by Sol on 12/7/17.
//  Copyright © 2017 Team 5. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
import FirebaseAuth

struct SellInfo{
    var sellAmount: Double
    var sellValue: String
    var sellTotalValue: String
    var sellDate: String
    init(){
        sellAmount = 0.0
        sellValue = ""
        sellTotalValue = ""
        sellDate = ""
    }
}

// Extension for Sell Stack View's Background Setup
public extension UIView {
    public func pinSell(to view: UIView) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
}

class SellView: UIViewController, UITextFieldDelegate {
    
    //-------------- INITIALIZE ------------------
    
    // UI Variables
    @IBOutlet weak var sellValueStackView: UIStackView!
    @IBOutlet weak var sellValueLbl: UILabel!
    @IBOutlet weak var sellCurrencyNameLbl: UILabel!
    @IBOutlet weak var sellInput: UITextField!
    @IBOutlet weak var sellTotalValueLbl: UILabel!
    @IBOutlet weak var sellButtonLbl: UIButton!
    
    // Wallet Variable
    var sellWalletData = WalletView()
    var hasSellItem: Bool!
    
    // Currency's Value Update Variables
    var default_data: UserDefaults!
    var currentSellValue: Double!
    var updateTimer: Timer!
    
    // Data Variables
    var sellItem = SellInfo()
    var sellCryptoData = CryptoCurrency()
    var sellRegularData = currency()
    var currencySellName: String = ""
    var currencySellAmount: Double = 0
    var totalSellValue: Double = 0.0
    var wtbSymbol: String! // wtb: want to buy
    var wtsSymbol: String! // wts: want to sell
    var isSellOK: Bool = false
    
    
    // Date Variable
    let date = Date()
    let calendar = Calendar.current
    
    // Background Variables
    var backgroundImage = UIImage()
    var backgroundImageView = UIImageView()
    var backgroundImageName = ""
    
    // Firebase Variable Initailize
    var ref : DatabaseReference!
    var refPurchase: DatabaseReference!
    var user = Auth.auth().currentUser
    
    //-------------- PROCESS ------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup view's background
        backgroundImageName = "background6.png"
        setBackgroundImage()
        pinBackground(backgroundView, to: sellValueStackView)
        
        // Setup UI labels
        sellInput.delegate = self
        sellTotalValueLbl.text = "0.0"
        setSellCurrencyName(crytoStr: sellCryptoData.symbol, regStr: sellRegularData.symbol)
        setSellValueLbl(cryptoStr: sellCryptoData.price_usd, regStr: String(sellRegularData.price))
        
        // Setup Sell Value Update variables
        default_data = UserDefaults.init(suiteName: "Fetch Data API")
        updateTimer = Timer.scheduledTimer(timeInterval: 90, target: self, selector: #selector(SellView.updateCurrentSellValue), userInfo: nil, repeats: true)
        
        // Setup Keyboard type for TextInput and TapRecognizer
        sellInput.keyboardType = UIKeyboardType.decimalPad
        let tapRegcognizer = UITapGestureRecognizer()
        tapRegcognizer.addTarget(self, action: #selector(self.didTapView))
        self.view.addGestureRecognizer(tapRegcognizer)
        
        // Hide the sell button when view loaded
        sellButtonLbl.isHidden = true
    }
    
    // ---- Stack View's Background Setup functions ----
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 30.0
        return view
    }()
    
    private func pinBackground(_ view: UIView, to stackView: UIStackView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        stackView.insertSubview(view, at: 0)
        view.pinSell(to: stackView)
    }
    
    // ---- Sell Button function ----
    @IBAction func sellButton(_ sender: Any) {
        let sellDay = calendar.component(.day, from: date)
        let sellMonth = calendar.component(.month, from: date)
        let sellYear = calendar.component(.year, from: date)
        
        if(hasSellItem == true)
        {
            isSellOK = true
            if (sellInput.text != ""){
                sellItem.sellAmount = Double(sellInput.text!)!
            }
            
            if (sellTotalValueLbl.text != ""){
                sellItem.sellTotalValue = sellTotalValueLbl.text!
            }
            
            sellItem.sellValue = sellValueLbl.text!
            sellItem.sellDate = "\(sellDay) - \(sellMonth) - \(sellYear)"
            sellDeposit()
            sellWithdraw()
            addSellInfoToDB()
            addSellCurrAmountToDB(amountInput: self.sellInput.text!)
            sellingAlert(buyAlert: "Selling successful!")
            
        }
        
        
    }
    
    // ---- Sell Value Update function ----
    @objc func updateCurrentSellValue(){
        if(sellCryptoData.symbol != ""){
            let crypValue = self.default_data?.double(forKey: sellCryptoData.symbol)
            sellValueLbl.text = "$" + String(crypValue!)
        }else{
            let regValue = self.default_data?.double(forKey: sellRegularData.symbol)
            sellValueLbl.text = "$" + String(regValue!)
        }
    }
    
    // ---- UI Setup functions ----
    func setSellCurrencyName(crytoStr:String, regStr:String)
    {
        if (crytoStr != ""){
            sellCurrencyNameLbl.text = crytoStr
            wtsSymbol = crytoStr
        } else{
            sellCurrencyNameLbl.text = String(regStr.characters.suffix(3))
            wtsSymbol = regStr
        }
        wtbSymbol = "USD"
    }
    
    func setSellValueLbl(cryptoStr:String, regStr:String){
        if (cryptoStr != ""){
            sellValueLbl.text = "$" + cryptoStr
        }else{
            sellValueLbl.text = "$" + regStr
        }
    }
    
    // ---- View's Background Setup functions ----
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

    // ---- TapRecognizer Setup functions ----
    @objc func didTapView(){
        self.view.endEditing(true)
        if(sellInput.text != "")
        {
            calculateSellTotal()
            loadBalance()
            sellButtonLbl.isHidden = false
        }
        
    }
    
    // ---- Alert Setup function ----
    func sellingAlert(buyAlert:String){
        let alert = UIAlertController(title: buyAlert, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "default action"), style: .`default`, handler: { _ in NSLog("The \"OK\" alert occured")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // ---- Clearing TextField and Label function ----
    func clearSell(){
        if(hasSellItem == false){
            sellInput.text = ""
            sellTotalValueLbl.text = "0.0"
            sellButtonLbl.isHidden = true
        }else if (isSellOK == true){
            sellInput.text = ""
            sellTotalValueLbl.text = "0.0"
            sellButtonLbl.isHidden = true
            isSellOK = false;
        }
    }
    
    // ---- Sell Wallet ----
    
    func checkOwnedCurrExist(){
        for item in sellWalletData.balanceList{
            if(item.type == wtsSymbol){
                if(item.amount == "" || Double(item.amount)! < 0.0 || Double(item.amount)! < Double(self.sellInput.text!) as! Double){
                    hasSellItem = false
                    sellingAlert(buyAlert: "Not enough item to sell")
                    clearSell()
                }else{
                    hasSellItem = true
                    currencySellAmount = Double(item.amount)!
                    print ("Has Sell Item!")
                }
            }
        }
    }
    
    func loadBalance(){
        sellWalletData.balanceList = [Balance]()
        ref = Database.database().reference().child("Balance").child((user?.uid)!)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            self.sellWalletData.numbOfBalance = Int(snapshot.childrenCount)
            if let dictionary = snapshot.value as? NSDictionary {
                for (key, value) in dictionary {
                    var balance = Balance(type1: "\(key)", amount1: "\(value)")
                    self.sellWalletData.balanceList.append(balance)
                }
                self.checkOwnedCurrExist()
            }})
    }
    
    func sellDeposit(){
        ref = Database.database().reference().child("Balance").child((user?.uid)!)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(self.wtbSymbol){
                var updateAmount : Double = 0.0
                if let balance = snapshot.value as? NSDictionary {
                    var currentAmount : Double = Double(balance[self.wtbSymbol] as! String)!
                    updateAmount = currentAmount + Double(self.totalSellValue)
                    DispatchQueue.main.async {
                        self.ref = Database.database().reference()
                        self.ref.child("Balance").child((self.user?.uid)!).updateChildValues([self.wtbSymbol: String(updateAmount)])
                    }
                }
            }
            else{
                DispatchQueue.main.async {
                    self.ref = Database.database().reference().child("Balance").child((self.user?.uid)!)
                    self.ref.updateChildValues([self.wtbSymbol: self.totalSellValue])
                }
            }})
    }
    
    func sellWithdraw(){
        ref = Database.database().reference().child("Balance").child((user?.uid)!)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            var updateAmount : Double = 0.0
            if let balance = snapshot.value as? NSDictionary {
                var currentAmount : Double = Double(balance[self.wtsSymbol] as! String)!
                updateAmount = currentAmount - Double(self.sellInput.text!)!
                DispatchQueue.main.async {
                    self.ref = Database.database().reference()
                    self.ref.child("Balance").child((self.user?.uid)!).updateChildValues([self.wtsSymbol: String(updateAmount)])
                    self.clearSell()
                }
            }})
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
    
    // ---- Database Upload functions ----
    func addSellInfoToDB()
    {
        if(MainView.isCryptoSelect == true)
        {
            currencySellName = sellCryptoData.name
        }
        else
        {
            currencySellName = sellRegularData.symbol
        }
        ref = Database.database().reference()
        
        let info = [ "data: " :  sellItem.sellDate as String, "Amount" :  String(sellItem.sellAmount) as String, "Cost" : sellValueLbl.text, "TotalPrice": "+" + String(sellItem.sellTotalValue) as String, "Type" : "Sell" ]
        ref.child("Information").child((user?.uid)!).child(currencySellName).childByAutoId().updateChildValues(info)
        
    }
    
    func addSellCurrAmountToDB(amountInput : String)
    {
        
        if(MainView.isCryptoSelect == true)
        {
            currencySellName = sellCryptoData.name
        }
        else
        {
            currencySellName = sellRegularData.symbol
        }
        ref = Database.database().reference()
        
        currencySellAmount = currencySellAmount - Double(amountInput)!
        
        let amount = [ "Amount: " : String(currencySellAmount) as String]
        ref.child("Amount").child((user?.uid)!).child(currencySellName).updateChildValues(amount)
        
    }
    // ---- Sell Currency Value function ----
    func calculateSellTotal(){
        if(sellCryptoData.price_usd != ""){
            let cryptValue = Double(sellCryptoData.price_usd)
            totalSellValue = Double(sellInput.text!)! * cryptValue!
            totalSellValue = round(1000*totalSellValue) / 1000
        }else{
            let regValue = Double(sellRegularData.price)
            totalSellValue = Double(sellInput.text!)! * regValue
            totalSellValue = round(1000*totalSellValue) / 1000
        }
        
        sellTotalValueLbl.text = "$" + String(totalSellValue)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
