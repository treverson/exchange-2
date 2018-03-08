const expect = require('chai').expect
const JotaliToken = artifacts.require('./JotaliToken')
const { assertRevert } = require('./utils')

let totalSupply = null
let owner = null
let deployed = null
let account_one = null
let account_two = null
let balanceOwner = null

contract('JotaliToken', (accounts) => {

  beforeEach(async () => {
    deployed = await JotaliToken.deployed()
  })

  it('owner should own all the supply of tokens', async () => {
    totalSupply = (await deployed.totalSupply.call()).toNumber()
    owner = accounts[0]
    balanceOwner = (await deployed.balanceOf(owner)).toNumber()
    assert.equal(balanceOwner, totalSupply, 'Owner does not own all the tokens')
  })
})
