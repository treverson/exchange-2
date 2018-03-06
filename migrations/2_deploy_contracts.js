var JotaliToken = artifacts.require('./JotaliToken.sol')
var JotaliExchange = artifacts.require('./JotaliExchange.sol')

module.exports = function(deployer) {
  deployer.deploy(JotaliToken)
  deployer.deploy(JotaliExchange)
}
