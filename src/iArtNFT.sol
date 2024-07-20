// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

// Importing OpenZeppelin contracts
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/utils/Base64.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

contract iArtNFT is ERC721URIStorage, Ownable {
    uint256 public currentTokenId;
    
    /// @notice Prices established when 1 eth = US$3400
    uint128 public firstTimePrice = 15_000_000 gwei;
    uint128 public normalPrice = 45_000_000 gwei;
    uint128 public offerPrice = 15_000_000 gwei;
    string public external_url;

    bool offerTime = false;
    
    using Strings for uint256;

    struct nftData {
        uint256 tokenId;
        uint256 creationDate;
        string paintingName;
        string paintingDescription;
        string nftImageIpfsHash;
    }

    mapping (address => uint256[]) public ownedNFTs;
    mapping(uint256 => nftData) public nftList;

    event nftMinted(uint256 tokenId);

    constructor() ERC721("iART-NFT", "iAN") Ownable(msg.sender) {

    }

    modifier mintFulfillment() {
        uint128 cost = normalPrice;

        if (offerTime == true) {
            cost = offerPrice;
        }
        else if (ownedNFTs[msg.sender].length == 0) {
            cost = firstTimePrice;
        }

        require(msg.value >= cost, "You did not send the correct amount");
        _;
    }

    function setFirstTimePrice(uint128 _firstTimePrice) external onlyOwner {
        firstTimePrice = _firstTimePrice;
    }
    
    function setNormalPrice(uint128 _normalPrice) external onlyOwner {
        normalPrice = _normalPrice;
    }

    function setOfferTime(bool _offerTime) external onlyOwner {
        offerTime = _offerTime;
    }

    function setOfferPrice(uint128 _offerPrice) external onlyOwner {
        offerPrice = _offerPrice;
    }

    function setExternalUrl(string memory _external_url) external onlyOwner {
        external_url = _external_url;
    }

    function mintToPayer(
        string memory _paintingName, 
        string memory _paintingDescription,
        string memory _nftImageIpfsHash
    ) external payable mintFulfillment {
        // Anyone can mint
        require(bytes(_nftImageIpfsHash).length > 0, "IPFS Image Hash is needed");

        uint256 tokenId = ++currentTokenId;

        nftList[tokenId] = nftData({
            tokenId: tokenId,
            creationDate: block.timestamp,
            paintingName: _paintingName,
            paintingDescription: _paintingDescription,
            nftImageIpfsHash: _nftImageIpfsHash
        });
        
        // Mint the NFT and transfer it to the payer
        mint(msg.sender, tokenId, _nftImageIpfsHash);

        emit nftMinted(tokenId);
    }

    function mint(address to, uint256 tokenId, string memory _nftImageIpfsHash) public {
        mintFrom(to, tokenId, _nftImageIpfsHash);
    }

    function mintFrom(address to, uint256 tokenId, string memory _nftImageIpfsHash) internal {
        _safeMint(to, tokenId);
        updateMetaData(tokenId, _nftImageIpfsHash);
    }

    // Update MetaData
    function updateMetaData(uint256 tokenId, string memory _nftImageIpfsHash) internal {
        nftData memory nftInfo = nftList[tokenId];

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Maintenance Certificate",',
                        '"description": "This digital certificate serves as authentic evidence that the specified maintenance operations were performed under specific conditions",',
                        '"external_url": "', external_url,'",',
                        '"image": "', _nftImageIpfsHash, '",',
                        '"attributes": [',
                            '{"trait_type": "paintingName",',
                            '"value": "', nftInfo.paintingName ,'"},',
                            '{"trait_type": "creationDate",',
                            '"value": ', nftInfo.creationDate ,'}'
                        ']}'
                    )
                )
            )
        );
        // Create token URI
        string memory finalTokenURI = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        // Set token URI
        _setTokenURI(tokenId, finalTokenURI);
    }

    function getOwnedNFTs(address _walletAddress) public view onlyOwner returns (nftData[] memory) {
        uint256[] memory walletNFTs = ownedNFTs[_walletAddress];
        nftData[] memory result = new nftData[](walletNFTs.length);
        
        for (uint i = 0; i < walletNFTs.length; i++) {
            result[i] = nftList[walletNFTs[i]];
        }
        
        return result;
    }

    // The following function is an override required by Solidity.
    
    function tokenURI(uint256 tokenId)
        public view override(ERC721URIStorage) returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
