//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

error PriceMustBeAboveZero();
error NotApprovedForMarketPlace();
error AlreadyListed(address nftAddress, uint256 tokenId);
error NotOwner();

contract NftMarketplace {
    struct Listing {
        uint256 price;
        address seller;
    }
    //Events
    event ItemListed(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );

    //NFT Contract Addresss --> NFT TokenID -->Listing
    mapping(address => mapping(uint256 => Listing)) private s_Listing;

    //Modifiers
    modifier notListed(
        address nftAddress,
        uint256 tokenId,
        address owner
    ) {
        Listing memory listing = s_Listing[nftAddress][tokenId];
        if (listing.price > 0) {
            revert AlreadyListed(nftAddress, tokenId);
        }
        _;
    }

    modifier isOwner(
        address nftAddress,
        uint256 tokenId,
        address spender
    ) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if (spender != owner) {
            revert NotOwner();
        }
        _;
    }

    //////////////////
    //Main Functions///
    /////////////////
    function listItem(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    ) external notListed(nftAddress, tokenId, msg.sender) isOwner(nftAddress, tokenId, msg.sender) {
        if (price <= 0) {
            revert PriceMustBeAboveZero();
        }
        IERC721 nft = IERC721(nftAddress);
        if (nft.getApproved(tokenId) != address(this)) {
            revert NotApprovedForMarketPlace();
        }
        s_Listing[nftAddress][tokenId] = Listing(price, msg.sender);
        emit ItemListed(msg.sender, nftAddress, tokenId, price);
    }
}

// Creating a Decentralized NFT MArket Place

// Features:
// l `listItem`
// 2 `buyItem`
// 3 `updatePrice`
// 4 `delist the Item`
// 5 `Withdraw the Funds`
