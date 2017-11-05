local pg_driver = require "pgmoon"
local encode = require "cjson.safe".encode
local type = type
local tostring = tostring
local setmetatable = setmetatable
local error = error
local table_concat = table.concat
local string_format = string.format

local CONNECT_TABLE = { 
        host     = "127.0.0.1", 
        port     = 5432, 
        database = "test", 
        user     = 'postgres', 
        password = '111111', }
local CONNECT_TIMEOUT = 3000
local IDLE_TIMEOUT = 10000
local POOL_SIZE = 50

local function query(statement)
    local db, res, ok, err
    db = pg_driver.new(CONNECT_TABLE) -- always success
    db:settimeout(CONNECT_TIMEOUT) 
    res, err = db:connect()
    if not res then
        return nil, err
    end
    res, err =  db:query(statement) 
    if res ~= nil then
        ok, err = db:keepalive(IDLE_TIMEOUT, POOL_SIZE)
        if not ok then
            return nil, 'fail to set_keepalive:'..err
        end
    end
    if err then
        ngx.log(ngx.ERR, statement)
    end
    return res, err
end

local function main()
    
    local res, err = query('drop table if exists t1;create table t1(id INT PRIMARY KEY NOT NULL);')
    if err then
        return ngx.say(err)
    end
    local t = {}
    for i=1,10^4 do
        local res, err = query('insert into t1 (id) values1 (1);')
        if err then
            t[err]= (t[err] or 0) + 1
        end
    end
    ngx.say(encode(t))
end

main()