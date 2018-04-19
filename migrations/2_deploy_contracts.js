const JotaliToken = artifacts.require('./JotaliToken.sol')
const JotaliExchange = artifacts.require('./JotaliExchange.sol')

module.exports = function(deployer) {
  deployer.deploy(JotaliToken)
  deployer.deploy(JotaliExchange)
}
