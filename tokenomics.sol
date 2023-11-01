pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract GENToken is IERC20 {
    string public constant name = "GEN";
    string public constant symbol = "GEN";
    uint8 public constant decimals = 18;
   
    
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    
    // Token allocations
    uint256 private constant ECOSYSTEM_SUPPLY = 120000000 * 10**decimals;   // 48% of total supply
    uint256 private constant TREASURY_SUPPLY = 40000000 * 10**decimals;     // 10% of total supply
    uint256 private constant CORE_TEAM_SUPPLY = 40000000 * 10**decimals;    // 10% of total supply
    uint256 private constant PUBLIC_SALE_SUPPLY = 40000000 * 10**decimals;   // 10% of total supply
    uint256 private constant PRIVATE_SALE_SUPPLY = 20000000 * 10**decimals;  // 5% of total supply
    uint256 private constant LIQUIDITY_SUPPLY = 16000000 * 10**decimals;     // 4% of total supply
    uint256 private constant COMMUNITY_SUPPLY = 36000000 * 10**decimals;     // 9% of total supply
    uint256 private constant LEGAL_SUPPLY = 16000000 * 10**decimals;         // 4% of total supply
    uint256 private constant TAXES_SUPPLY = 16000000 * 10**decimals;         // 4% of total supply
    
    address private _ecosystemWallet;
    address private _treasuryWallet;
    address private _coreTeamWallet;
    address private _publicSaleWallet;
    address private _privateSaleWallet;
    address private _liquidityWallet;
    address private _communityWallet;
    address private _legalWallet;
    address private _taxesWallet;
    
    uint256 private _ecosystemReleased;
    uint256 private _treasuryReleased;
    uint256 private _coreTeamReleased;
    uint256 private _publicSaleReleased;
    uint256 private _privateSaleReleased;
    
    uint256 private constant LOCK_DURATION = 30 days;  // Lock duration for the ecosystem and public sale allocations
    
    uint256 private _lockEndTime;
    
    constructor(
        address ecosystemWallet,
        address treasuryWallet,
        address coreTeamWallet,
        address publicSaleWallet,
        address privateSaleWallet,
        address liquidityWallet,
        address communityWallet,
        address legalWallet,
        address taxesWallet
    ) {
        _ecosystemWallet = ecosystemWallet;
        _treasuryWallet = treasuryWallet;
        _coreTeamWallet = coreTeamWallet;
        _publicSaleWallet = publicSaleWallet;
        _privateSaleWallet = privateSaleWallet;
        _liquidityWallet = liquidityWallet;
        _communityWallet = communityWallet;
        _legalWallet = legalWallet;
        _taxesWallet = taxesWallet;
        
        _totalSupply = 250000000 * 10**decimals;  // Total supply of GEN tokens
        
        // Allocate initial token supply
        _balances[ecosystemWallet] = ECOSYSTEM_SUPPLY;
        _balances[treasuryWallet] = TREASURY_SUPPLY;
        _balances[coreTeamWallet] = CORE_TEAM_SUPPLY;
        _balances[publicSaleWallet] = PUBLIC_SALE_SUPPLY;
        _balances[privateSaleWallet] = PRIVATE_SALE_SUPPLY;
        _balances[liquidityWallet] = LIQUIDITY_SUPPLY;
        _balances[communityWallet] = COMMUNITY_SUPPLY;
        _balances[legalWallet] = LEGAL_SUPPLY;
        _balances[taxesWallet] = TAXES_SUPPLY;
        
        // Set initial release amounts for ecosystem and public sale allocations
        _ecosystemReleased = 12000000 * 10**decimals;  // 12% of ecosystem supply released initially
        _treasuryReleased = 4000000 * 10**decimals;    // 4% of treasury supply released initially
        _coreTeamReleased = 0;
        _publicSaleReleased = 10000000 * 10**decimals;  // 10% of public sale supply released initially
        _privateSaleReleased = 0;
        
        // Set lock end time for ecosystem and public sale allocations
        _lockEndTime = block.timestamp + LOCK_DURATION;
        
        emit Transfer(address(0), ecosystemWallet, ECOSYSTEM_SUPPLY);
        emit Transfer(address(0), treasuryWallet, TREASURY_SUPPLY);
        emit Transfer(address(0), coreTeamWallet, CORE_TEAM_SUPPLY);
        emit Transfer(address(0), publicSaleWallet, PUBLIC_SALE_SUPPLY);
        emit Transfer(address(0), privateSaleWallet, PRIVATE_SALE_SUPPLY);
        emit Transfer(address(0), liquidityWallet, LIQUIDITY_SUPPLY);
        emit Transfer(address(0), communityWallet, COMMUNITY_SUPPLY);
        emit Transfer(address(0), legalWallet, LEGAL_SUPPLY);
        emit Transfer(address(0), taxesWallet, TAXES_SUPPLY);
    }
    
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_balances[sender] >= amount, "Insufficient balance");
        
        if (sender == _ecosystemWallet && block.timestamp < _lockEndTime) {
            require(amount <= _ecosystemReleased, "Exceeded maximum allowed transfer for ecosystem allocation");
            _ecosystemReleased -= amount;
        }
        
        if (sender == _publicSaleWallet && block.timestamp < _lockEndTime) {
            require(amount <= _publicSaleReleased, "Exceeded maximum allowed transfer for public sale allocation");
            _publicSaleReleased -= amount;
        }
        
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        
        emit Transfer(sender, recipient, amount);
    }
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
