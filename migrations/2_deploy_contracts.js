var JotaliToken = artifacts.require("./JotaliToken.sol");

module.exports = function(deployer) {
  deployer.deploy(JotaliToken);
};
