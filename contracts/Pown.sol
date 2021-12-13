//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract Pown is Initializable, ERC721Upgradeable, AccessControlUpgradeable {
    event MintPown(uint256 bountyId, uint256 tokenId);

    bytes32 public constant MINT_ROLE = keccak256("MINT_ROLE");

    string private _baseURIForPown;
    // Last Used id (used to generate new ids)
    uint256 private lastId;

    // BountyId for each token
    mapping(uint256 => uint256) private _bounty;

    /**
     * @dev Gets the token uri
     * @return string representing the token uri
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        uint bountyId = _bounty[tokenId];
        return _strConcat(_baseURIForPown, _uint2str(bountyId), "/", _uint2str(tokenId), "");
    }

    /**
     * @dev Function to mint tokens
     * @param bountyId BountyId for the new token
     * @param to The address that will receive the minted tokens.
     * @return A boolean that indicates if the operation was successful.
     */
    function mintToken(uint256 bountyId, address to)
    public returns (bool)
    {
        require(hasRole(MINT_ROLE, msg.sender), "Not authorized to mint");
        lastId += 1;
        return _mintToken(bountyId, lastId, to);
    }

    /**
    * @dev Function to set baseURI
    * @param baseURI baseURI e.g. "https://foo.com/pown/"
    */
    function setBaseURI(string memory baseURI) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Not authorized to change baseURI");
        _baseURIForPown = baseURI;
    }

    function initialize(string memory _name, string memory _symbol, string memory __baseURI) public initializer {
        __ERC721_init(_name, _symbol);
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINT_ROLE, msg.sender);
        _baseURIForPown = __baseURI;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Upgradeable, AccessControlUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Function to mint tokens
     * @param bountyId BountyId for the new token
     * @param tokenId The token id to mint.
     * @param to The address that will receive the minted tokens.
     * @return A boolean that indicates if the operation was successful.
     */
    function _mintToken(uint256 bountyId, uint256 tokenId, address to) internal returns (bool) {
        // TODO Verify that the token receiver ('to') do not have already a token for the event ('bountyId')
        _mint(to, tokenId);
        _bounty[tokenId] = bountyId;
        emit MintPown(bountyId, tokenId);
        return true;
    }

    /**
     * @dev Function to convert uint to string
     * Taken from https://github.com/oraclize/ethereum-api/blob/master/oraclizeAPI_0.5.sol
     */
    function _uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    /**
     * @dev Function to concat strings
     * Taken from https://github.com/oraclize/ethereum-api/blob/master/oraclizeAPI_0.5.sol
     */
    function _strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e)
    internal pure returns (string memory _concatenatedString)
    {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        uint i = 0;
        for (i = 0; i < _ba.length; i++) {
            babcde[k++] = _ba[i];
        }
        for (i = 0; i < _bb.length; i++) {
            babcde[k++] = _bb[i];
        }
        for (i = 0; i < _bc.length; i++) {
            babcde[k++] = _bc[i];
        }
        for (i = 0; i < _bd.length; i++) {
            babcde[k++] = _bd[i];
        }
        for (i = 0; i < _be.length; i++) {
            babcde[k++] = _be[i];
        }
        return string(babcde);
    }
}
