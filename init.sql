-- Create table for tokens
CREATE TABLE tokens (
  address VARCHAR PRIMARY KEY, -- Token mint address
  program_id VARCHAR,          -- Program that created the token
  image_url VARCHAR,           -- Token logo URL
  name VARCHAR,                -- Token name
  symbol VARCHAR,              -- Token symbol
  decimals INT                 -- Token decimals
  -- tags JSON -- 🟡❓ Might be added later
);

-- Create table for pools
CREATE TABLE pools (
  address VARCHAR PRIMARY KEY,        -- Whirlpool pool address
  tick_spacing INT,                   -- Tick spacing of the pool
  fee_rate INT,                        -- Pool trading fee rate (bps)
  liquidity VARCHAR,                   -- Liquidity in sqrt format 🟡❓ Possibly unused
  sqrt_price VARCHAR,                  -- Current sqrt price
  tick_current_index INT,              -- Current tick index 🟡❓ Possibly unused
  token_mint_a VARCHAR REFERENCES tokens(address), -- Token A mint
  token_vault_a VARCHAR,               -- Vault address for token A 🟡❓ Possibly unused
  token_mint_b VARCHAR REFERENCES tokens(address), -- Token B mint
  token_vault_b VARCHAR,               -- Vault address for token B 🟡❓ Possibly unused
  has_warning BOOLEAN,                 -- Has pool warnings
  price VARCHAR,                       -- Current pool price 🟡❓ Possibly unused
  tvl_usdc VARCHAR,                    -- TVL in USDC
  yield_over_tvl VARCHAR,              -- Yield relative to TVL
  token_balance_a VARCHAR,             -- Current token A balance 🟡❓ Possibly unused
  token_balance_b VARCHAR,             -- Current token B balance 🟡❓ Possibly unused
  trade_enable_timestamp VARCHAR,     -- When trading was enabled

  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);


-- Create a trigger to update the updated_at field
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_updated_at
BEFORE UPDATE ON pools
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- Create table for periods (timeframes)
CREATE TABLE periods (
  code VARCHAR PRIMARY KEY -- Example: '24h', '7d', '30d', etc.
);

-- Insert default period values
INSERT INTO periods (code) VALUES 
('24h'),
('7d'),
('30d');

-- Create table for pool statistics
CREATE TABLE stats (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Auto-incremented ID
  pool_address VARCHAR REFERENCES pools(address),      -- Pool address
  period VARCHAR REFERENCES periods(code),             -- Statistics period ('24h', '7d', etc.)
  volume VARCHAR,                                      -- Trading volume
  fees VARCHAR,                                        -- Collected fees
  rewards VARCHAR,                                     -- Rewards
  yield_over_tvl VARCHAR,
  UNIQUE (pool_address, period)                               -- Yield relative to TVL
);

-- Create table for pool rewards
CREATE TABLE rewards (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Auto-incremented ID
  pool_address VARCHAR REFERENCES pools(address),      -- Pool address
  mint VARCHAR,                                        -- Reward token mint
  vault VARCHAR,                                       -- Reward token vault
  growth_global_x64 VARCHAR,                           -- Global reward growth in X64
  active BOOLEAN,
  UNIQUE (pool_address, mint)                                      -- Reward emission active
  -- emissions_per_second NUMERIC                         -- Emissions per second 🟡❓ Possibly unused
  -- emissions_per_second_x64 VARCHAR -- 🟡❓ Possibly unused, commented for now
);

-- (Optional) Future table for locked liquidity
-- CREATE TABLE locked_liquidity (
--   id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Auto-incremented ID
--   pool_address VARCHAR REFERENCES pools(address),      -- Pool address
--   name VARCHAR,                                        -- Locked liquidity name 🟡❓ Possibly unused
--   locked_percentage NUMERIC                            -- Locked liquidity percentage 🟡❓ Possibly unused
-- );

-- Indexes to speed up lookups
CREATE INDEX idx_pools_token_mint_a ON pools(token_mint_a);
CREATE INDEX idx_pools_token_mint_b ON pools(token_mint_b);
CREATE INDEX idx_stats_pool_address ON stats(pool_address);
CREATE INDEX idx_rewards_pool_address ON rewards(pool_address);
