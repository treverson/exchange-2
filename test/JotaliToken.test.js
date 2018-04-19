const expect = require('chai').expect
const JotaliToken = artifacts.require('JotaliToken')
const utils = require('./utils')
const BigNumber = web3.BigNumber

const TOTAL_SUPPLY = 100000000000000000
const ADDRESS = '0x50Ebe9ad50DCf1Be1A35570E29587fa9F6eCDB46'

let jtl = null
let accounts = null
let transfer_event = null
let owner = null
let owner_balance = null
let acct_one = null
let starting_balance_one = null
let ending_balance_one = null
let acct_two = null
let starting_balance_two = null
let ending_balance_two = null
let acct_three = null

contract('JTL ERC20 Token', async (accounts) => {

  beforeEach(async () => {
    jtl = await JotaliToken.deployed()
  })

  it('should fail because the function doest not exist in Contract', async () => {
    try {
      await jtl.nonExistentFunction()
    } catch (error) {
      expect(error.name).to.equal('TypeError')
      return true
    }
    throw new Error('I should never see this!')
  })

  it('should test that the contract is owned by the correct address', async () => {
    owner = await jtl.owner.call()
    console.log('Contract owner --> ', owner)
    expect(owner.valueOf()).to.equal(ADDRESS)
  })

  it('should test that the contract is deployed by the correct address', async () => {

  })

  it('should initialize with the name JTL Token', async () => {
    const name = await jtl.name.call()
    expect(name.valueOf()).to.equal('JTL Token')
  })

  it('should have the token symbol JTL', async () => {
    const symbol = await jtl.symbol.call()
    expect(symbol.valueOf()).to.equal('JTL')
  })

  it('should have 8 decimal places', async () => {
    const decimals = (await jtl.decimals.call()).toNumber()
    expect(decimals.valueOf()).to.equal(8)
  })

  it('should have an initial owner balance of 1 Billion JTL Tokens', async () => {
    owner = accounts[0]
    owner_balance = (await jtl.balanceOf(owner)).toNumber()

    expect(owner_balance).to.equal(TOTAL_SUPPLY)
  })

  it('second account should not own any tokens at initialization', async () => {
    acct_two = accounts[1]
    starting_balance_two = (await jtl.balanceOf(acct_two)).toNumber()

    expect(starting_balance_two).to.equal(0)
  })

  it('should correctly transfer JTL tokens', async () => {
    acct_one = accounts[0]
    acct_two = accounts[1]
    amount = 1000

    starting_balance_one = (await jtl.balanceOf(acct_one)).toNumber()
    starting_balance_two = (await jtl.balanceOf(acct_two)).toNumber()

    transfer_event = await jtl.transfer(acct_two, amount, {from: acct_one})

    ending_balance_one = (await jtl.balanceOf(acct_one)).toNumber()
    ending_balance_two = (await jtl.balanceOf(acct_two)).toNumber()

    expect(ending_balance_one).to.equal(starting_balance_one - amount)
    expect(ending_balance_two).to.equal(starting_balance_two + amount)
  })

  it('should not be possible to transfer more tokens than you have', async () => {
    acct_two = accounts[1]
    acct_three = accounts[2]
    amount = 1000

    await utils.assertRevert(jtl.transfer(acct_three, amount, {from: acct_two}))
  })

  it('should not allow a non-owner transfer of ownership', async () => {
    acct_two = accounts[1]
    await utils.assertRevert(jtl.transferOwnership(acct_two, {from: acct_two}))
  })

})
