const expect = require('chai').expect
const JotaliToken = artifacts.require('./JotaliToken')
const utils = require('./utils')

let totalSupply = null
let owner = null
let deployed = null
let account_one = null
let account_two = null
let balanceOwner = null
let balance_two = null

contract('JotaliToken', (accounts) => {

  beforeEach(async () => {
    deployed = await JotaliToken.deployed()
  })

  it('should fail because function does not exist in contract', async () => {
    try {
      await deployed.nonExistentFunction()
    } catch (error) {
      return true
    }
    throw new Error('I should never see this!')
  })

  it('owner should own all the supply of tokens', async () => {
    owner = accounts[0]
    totalSupply = (await deployed.totalSupply.call()).toNumber()
    balanceOwner = (await deployed.balanceOf(owner)).toNumber()
    assert.equal(balanceOwner, totalSupply, 'Owner does not own all the tokens')
  })

  it('second account should not own any tokens', async () => {
    account_two = accounts[1]
    balance_two = (await deployed.balanceOf(account_two)).toNumber()
    assert.equal(balance_two, 0, 'Second account somehow got tokens')
  })

})
