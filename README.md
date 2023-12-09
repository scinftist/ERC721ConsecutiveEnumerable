# ERC721ConsecutiveEnumerable
ERC721Consecutive make batch minting possible but it is not IERC721Enumerable compatible.
the following contract Is a proof of concept that shows with some minor changes to ERC721Consecutive and ERC721Enumerable.
it can be merge to one contract. with following features:

- batch minting during constructor.
- single minting after deployment.
- single burning of a token.
- full IERC721Enumerable compatibility.
- all of the indexing functions are O(1)
----
current contract is base on OpenZeppelin implementation of ERC721 v4.9

version V5.0 is on the way.

to see techniacal explanation of this contract see this [issue](https://github.com/OpenZeppelin/openzeppelin-contracts/issues/3985)
