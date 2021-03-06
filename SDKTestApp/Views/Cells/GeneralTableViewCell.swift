//
//  GeneralTableViewCell.swift
//  SDKTestApp
//
//  Created by Dharmesh Vaghani on 08/08/19.
//  Copyright © 2019 VaultWallet. All rights reserved.
//

import UIKit
import AbstraktSDK

class GeneralTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblAccountName: UILabel!
    @IBOutlet weak var lblAccountValue: UILabel!
    @IBOutlet weak var lblAccountBalance: UILabel!
    @IBOutlet weak var lblAccountNumber: UILabel!
    @IBOutlet weak var lblAccountType: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        lblAccountNumber.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setAccountDetails(account: Account) {
        self.lblAccountNumber.isHidden = false
        self.lblAccountName.text = account.nickname ?? ""
        self.lblAccountType.isHidden = true
        
        var accountType = ""
        
        if let blockchainNetwork = account.blockchainNetwork {
            accountType = Constant.coinNames[blockchainNetwork.rawValue]
        }
        
        self.lblAccountBalance.text = "$0.00"
        self.lblAccountValue.text = "0.00 \(accountType)"
        
        guard let address = account.address, let blockchainNetwork = account.blockchainNetwork else {
            return
        }
        
        self.lblAccountNumber.text = address
        
        let roundTo = getRoundDigit(for: blockchainNetwork)
        
        Abstrakt.shared.getAccountBalance(accountAddress: address, blockchainNetwork: blockchainNetwork) { (accountBalance, accountConversionBalance) in
            self.lblAccountValue.text = accountBalance.rounded(toPlaces: roundTo).toString(decimal: roundTo) + " " + accountType
            self.lblAccountBalance.text = Constant.getDollarDisplayValue(amount: accountConversionBalance)
        }
    }
    
    func setTransactionDetails(transaction: Transaction) {
        self.lblAccountType.isHidden = false
        self.lblAccountName.text = transaction.from ?? ""
        
        self.lblAccountType.text = self.getDateAndTime(timeStamp: transaction.timestamp ?? Date())
        
        var accountType = ""
        guard let blockchainNetwork = transaction.blockchainNetwork  else {
            return
        }
        
        accountType = Constant.coinNames[blockchainNetwork.rawValue]
        
        self.lblAccountBalance.text = "$0.00"
        var amount = transaction.value ?? 0
        
        if blockchainNetwork != BlockchainNetwork.BitcoinTestnet && blockchainNetwork != BlockchainNetwork.BitcoinMainnet {
            amount = amount / 1000000000000000000
        }
        
        let roundTo = getRoundDigit(for: blockchainNetwork)
        
        self.lblAccountValue.text = amount.rounded(toPlaces: roundTo).toString(decimal: roundTo) + " " + accountType
        
        if let blockchainNetwork = transaction.blockchainNetwork, let marketValue = Abstrakt.shared.getMarketValue(blockchainNetwork: getMainnetfromTestnetForMarketValue(blockchainNetwork: blockchainNetwork)) {
            let convertedClosePrice = marketValue.closePrice!.replacingOccurrences(of: "$", with: "")
            let variation = Double(convertedClosePrice)! * amount
            
            self.lblAccountBalance.text = Constant.getDollarDisplayValue(amount: variation)
        }
    }
    
    //MARK: - Helper Methods
    
    func getDateAndTime(timeStamp: Date) -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a dd/MM/yy"
        return dateFormatter.string(from: timeStamp)
    }
    
    func getMainnetfromTestnetForMarketValue(blockchainNetwork: BlockchainNetwork) -> BlockchainNetwork {
        var blockchainNetwork = blockchainNetwork
        switch blockchainNetwork {
        case .AionTestnet:
            blockchainNetwork = .AionMainnet
        case .EthTestnet:
            blockchainNetwork = .EthMainnet
        case .BitcoinTestnet:
            blockchainNetwork = .BitcoinMainnet
        default:
            break
        }
        
        return blockchainNetwork
    }
    
    func getRoundDigit(for blockchainNetwork: BlockchainNetwork) -> Int {
        switch blockchainNetwork {
        case .AionMainnet, .AionTestnet, .EthMainnet, .EthTestnet:
            return 9
        case .BitcoinTestnet, .BitcoinMainnet:
            return 8
        }
    }
}

