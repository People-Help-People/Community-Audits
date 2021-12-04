// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.6 <0.9.0;

import "./Asset.sol";
import "./TruthToken.sol";

// store a map of asset contracts
// onboard assets to master if not available

contract CommunityAudits {
    Asset[] public assetContracts;
    mapping(address => address) public assetContractsMap;
    TruthToken public truthTokens;
    mapping(address => bool) public users; // later to be converted to an add=>add map for profile NFTs

    constructor() {
        truthTokens = new TruthToken(1614317 * 10**18);
    }
        
    modifier checkExistingUser(address _user) {
        require(
            users[_user] == false,
            "User already registered."
        );
        _;
    }

    function registerUser(
        address _user
    ) public checkExistingUser(_user){
        users[_user]=true;
        truthTokens.transfer(_user,10*10**18);
    }

    function truthBalance(address _user) view public returns(uint256){
        return truthTokens.balanceOf(_user);
    }


    function create(
        address _contract,
        string memory _name,
        string memory _symbol,
        string memory _imageURL,
        CATEGORY _category
    ) public {
        Asset newContract = new Asset(
            _contract,
            _name,
            _symbol,
            _imageURL,
            _category
        );
        assetContracts.push(newContract);
        assetContractsMap[_contract] = address(newContract);
    }

    modifier checkAsset(address _contract) {
        require(
            assetContractsMap[_contract] != address(0),
            "Sorry this asset is not available, Please consider adding it to the system."
        );
        _;
    }

    function getData(address _contract)
        public
        view
        checkAsset(_contract)
        returns (Data memory)
    {
        Asset assetContract = Asset(address(assetContractsMap[_contract]));
        return assetContract.data();
    }

    function getComments(address _contract)
        public
        view
        checkAsset(_contract)
        returns (Comment[] memory)
    {
        Asset assetContract = Asset(address(assetContractsMap[_contract]));
        return assetContract.getComments();
    }

    function rateAsset(
        address _contract,
        uint256 _technicalImplementation,
        uint256 _trustFactor,
        uint256 _founderReliability
    ) public checkAsset(_contract) {
        Asset assetContract = Asset(address(assetContractsMap[_contract]));
        assetContract.rate(
            msg.sender,
            _technicalImplementation,
            _trustFactor,
            _founderReliability
        );
    }

    function commentAsset(address _contract, string memory message)
        public
        checkAsset(_contract)
    {
        Asset assetContract = Asset(address(assetContractsMap[_contract]));
        assetContract.postComment(msg.sender, message);
    }

    function voteComment(
        address _contract,
        uint256 _comment,
        VOTE _vote
    ) public checkAsset(_contract) {
        Asset assetContract = Asset(address(assetContractsMap[_contract]));
        assetContract.voteComment(msg.sender, _comment, _vote);
    }
}
