function authenticationPrompt()
    ngx.header.www_authenticate = 'Basic realm="Restricted by OpenResty"'
    ngx.exit(401)
end

function hasAccessByIp()
    local ip = ngx.var.remote_addr
    local domain = ngx.var.host
    local port = ngx.var.server_port

    local res, err = httpc:request_uri(os.getenv("AUTH_API_URL") .. "/ip.php", {
        method = "GET",
        query = "ip=" .. ip .. '&domain=' .. domain .. '&port=' .. port,
        headers = {
          ["Content-Type"] = "application/x-www-form-urlencoded",
        },
        keepalive_timeout = 60000,
        keepalive_pool = 10,
        ssl_verify = false
    })

    if res ~= nil then
        if (res.status == 200) then
            session.data.domains[domain] = true
            session:save()

            return true
        elseif (res.status == 403) then
            return false
        else
            session:close()
            ngx.say("Server error: " .. res.body)
            ngx.exit(500)
        end
    else
        session:close()
        ngx.say("Server error: " .. err)
        ngx.exit(500)
    end
end

function hasAccessByLogin()
    local header = ngx.var.http_authorization
    local domain = ngx.var.host
    local port = ngx.var.server_port

    if (header ~= nil) then
        header = ngx.decode_base64(header:sub(header:find(' ') + 1))
        login, password = header:match("([^,]+):([^,]+)")

        if login == nil then
            login = ""
        end
        if password == nil then
            password = ""
        end

        local res, err = httpc:request_uri(os.getenv("AUTH_API_URL") .. '/login.php', {
            method = "POST",
            body = "username=" .. login .. '&password=' .. password .. '&domain=' .. domain .. '&port=' .. port,
            headers = {
              ["Content-Type"] = "application/x-www-form-urlencoded",
            },
            keepalive_timeout = 60000,
            keepalive_pool = 10,
            ssl_verify = false
        })

        if res ~= nil then
            if (res.status == 200) then
                session.data.domains[domain] = true
                session:save()

                return true
            elseif (res.status == 403) then
                return false
            else
                session:close()
                ngx.say("Server error: " .. res.body)
                ngx.exit(500)
            end
        else
            session:close()
            ngx.say("Server error: " .. err)
            ngx.exit(500)
        end
    else
        return false
    end
end

os = require("os")

http = require "resty.http"
httpc = http.new()

session = require "resty.session".new()
session:start()

if (session.data.domains == nil) then
    session.data.domains = {}
end

local domain = ngx.var.host

if session.data.domains[domain] == nil then
    if (not hasAccessByIp() and not hasAccessByLogin()) then
        session:close()
        authenticationPrompt()
    else
        session:close()
    end
else
    session:close()
end
