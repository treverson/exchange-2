## Jotali Decentralized Exchange on Ethereum
+ This app powers [https://exchange.jotali.co](https://exchange.jotali.co)

## Getting Started

## Gitflow Process

• Our `master` branch is always the version of the application which is running live. Our master branch is never touched or committed directly to.

• The `develop` branch is the main working branch of the application for launching new features. We hardly ever make any commits directly to this branch much like master.

• When creating or adding a new feature create a new branch and name it accordingly. When the work is finished submit a Pull Request or merge to the develop branch, review, and implement. All feature branches begin with the prefix `feature` 
Example: `feature/posting`


• For fixing bugs or addressing issues please create a new branch and submit a pull request accordingly. All bug-fix branches begin with the prefix `bug-fix`
Example: `bug-fix/discover-text`

The goal of this flow is optimize for code reviews and cleanliness. The more segmented and contained work we can do the better we can focus on the task at hand, accomplish it, and implement.

For a more in-depth Gitflow understanding read here: https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow

# Software requirements
+ [Node.js](https://nodejs.org/en/) v8.1.2 or higher
+ [Truffle.js](http://truffleframework.com/) v4.1.0 (core: 4.1.0)
+ [Solidity](http://solidity.readthedocs.io/en/develop/installing-solidity.html) v0.4.19 (solc-js)
+ [npm](https://www.npmjs.com/) v5.7.1 or higher
