pragma solidity ^0.5.12;

import './Ownable.sol';

contract Token  {
    function balanceOf(address _owner)  public view returns (uint256 balance) {}
    function transfer(address _to, uint256 _value) public  returns (bool success) {}
    function transferFrom(address _from, address _to, uint256 _value) public  returns (bool success) {}
    function approve(address _spender, uint256 _value)  public returns (bool success) {}
    function allowance(address _owner, address _spender)  public view returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Changeetherwallet(address indexed _etherwallet,address indexed _newwallet);
}

contract StandardToken is Token {

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;
    
    function transfer(address _to, uint256 _value) public returns (bool success) 
    {
            if (balances[msg.sender] >= _value && _value > 0) 
            {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
            } 
            else 
            { 
                return false; 
                
            }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) 
    {
            if (balances[_from] >= _value  && _value > 0) 
            {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            emit Transfer(_from, _to, _value);
            return true;
            } 
            else 
            { 
                return false; 
                
            }
    }

    function balanceOf(address _owner)  public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }


}

contract AssetToken is StandardToken,Ownable {

 
    string public name;           
    uint256 public decimals;      
    string public symbol;         

    address owner;
    address tokenwallet;//= 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
    address payable etherwallet;//= 0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db;

    function changeEtherWallet(address payable _newwallet) onlyOwner() public returns (address) {
    
    etherwallet = _newwallet ;
    emit Changeetherwallet(etherwallet,_newwallet);
    return ( _newwallet) ;
}

    constructor() public {
        owner=msg.sender;
        tokenwallet= 0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c;
        etherwallet= 0x583031D1113aD414F02576BD6afaBfb302140225;
        name = "AssetToken";
        decimals = 8;            
        symbol = "AT";          
        totalSupply = 1000000000 * (10**decimals);        
        balances[tokenwallet] = totalSupply;               // Give the creator all initial tokens 
    }

    function getOwner() public view returns(address){
        return(owner);
    }
    
    
}

contract Asset is AssetToken{

mapping (address => Property) private landreg;
mapping (address => buyerdet) private buyreg;
mapping (uint => uint) private qtyremaining;
mapping (uint => address[]) private getlandbuyers;
//address[] private buyaddr;
mapping (address => uint) private mytoken;

struct Property{
    string name;
    uint landid;
    uint sellprice;
    uint units;
    uint no_of_buyers;
}

struct buyerdet{
    string name;
    uint landid;
    uint buyunit;
    uint buyprice;
}

 function registerLand(address _owneraddr, string memory _name, uint _landid, uint256 _value, uint _no_of_buyers) public returns (bool) 
    {
       Property storage p  = landreg[_owneraddr];
       p.name = _name;
       p.landid = _landid;
       p.sellprice = _value;
       p.no_of_buyers = _no_of_buyers;
       p.units = _value/_no_of_buyers;
       qtyremaining[p.landid] = p.units*_no_of_buyers;
       return true;
    }
    
    function buyLand(address  _buyeraddr, string memory _name, uint _landid, uint256 _buyunit, uint256 _buyprice) public  returns (bool) 
    {
       buyerdet storage bd  = buyreg[_buyeraddr];
       bd.name = _name;
       bd.landid = _landid;
       bd.buyunit = _buyunit;
       bd.buyprice = _buyprice;
       qtyremaining[bd.landid] -= _buyunit;
       getlandbuyers[bd.landid].push(_buyeraddr);
       transfer(_buyeraddr, _buyunit);
       return true;
    }
    
     function getlandqty(uint _landid) public view returns (uint) 
    {
       return qtyremaining[_landid];
    }
    
      function getbuyerforland(uint _landid) public view returns (address[] memory) 
    {
       // for(uint y=0;y<getlandbuyers[_landid].length;y++){
      // buyaddr.push(getlandbuyers[_landid]);
      //  }
        return getlandbuyers[_landid];
            }
    
  }

contract sendETHandtransferTokens is AssetToken {
    
        mapping(address => uint256) balances;
    
        uint256 public totalETH;
        event FundTransfer(address user, uint amount, bool isContribution);


       function () payable external {
        uint amount = msg.value;
        totalETH += amount;
        etherwallet.transfer(amount); 
        emit Transfer(tokenwallet,msg.sender,msg.value/1000000000);
        emit FundTransfer(msg.sender, amount, true);
    }
    
}
