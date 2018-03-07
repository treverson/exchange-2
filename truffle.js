require('dotenv').config()
var HDWalletProvider = require("truffle-hdwallet-provider")

module.exports = {
    solc: {
        optimizer: {
            enabled: true,
            runs: 200
        }
    },
    networks: {
        development: {
            host: "127.0.0.1",
            port: 7545,
            network_id: "*" // Match any network id
        },
        rinkeby: {
            provider: function() {
                return new HDWalletProvider(process.env.MNEMONIC, process.env.INFURA)
            },
            gas: 5000000,
            network_id: 1
        }
    }
}
