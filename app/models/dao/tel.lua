local _M = { _VERSION = '0.1' }

local mt = { __index = _M }

local cjson = require "cjson.safe"


local function dodbquery(dbname,q)
    local mysql = require "resty.mysql"
    local db = mysql:new()
    db:set_timeout(30000) -- 1 sec
    local ok, err, errno, sqlstate = db:connect({
        host = "127.0.0.1",
        port = "3306",
        user = "root",
        password = "yourpasswd",
        database = dbname, 
        max_packet_size=90485760
    })

    if not ok then
        ngx.say("failed to connect: ", err, ": ", errno, " ", sqlstate)
        return
    end
    local res, err, errno, sqlstate = db:query(q)

    if not res then
        ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
        return
    end
    local ok, err = db:set_keepalive()
    if not ok then
        ngx.say("failed to set keepalive: ", err)
        return
    end
    return res
end
function _M.getdepname(q)
    local name = tostring(q)
    local namedb = "%" .. name .. "%"
    namedb = ndk.set_var.set_quote_sql_str(namedb)
    local query="select id,depname from tel.department where depname like "..namedb .."order by id"
    local res = dodbquery("tel",query)
    local dep= {}
    local sel = "<select name='depselect' id='depselect'>"
    for i,row in ipairs(res) do
        sel=sel .."<option value='"..res[i].id.."'>"..res[i].depname.."</option>"
    end 
    sel = sel.."</select>"
    return sel 
end
function _M.getcontent(q)
    local name = tostring(q)
    local namedb = ndk.set_var.set_quote_sql_str(name)
    local query="select * from person where name = "..namedb ..""
    local res = dodbquery("tel",query)
    if #res ~= 0  then
        local query1="select id,depname from department"
        local res1= dodbquery("tel",query1) 
        local depname = "所属部门<select name='depselect' id='depselect'>"
        for i,row in ipairs(res1) do
            local valselected=''
            if res1[i].id == res[1].depid then
                valselected="selected"
            end
            depname=depname .."<option value='"..res1[i].id.."'".. valselected..">"..res1[i].depname.."</option>"
        end
        depname = depname .. "</select>"
        local sel='姓名拼音头字母:<input name="namepy" id="namepy" type="text" value="'..res[1].namepy..'"><br>'
        sel = sel ..'职位:<input name="job" id="job" type="text" value="'..res[1].job..'"><br>'
        sel = sel .. '办公电话:<input name="officetel" id="officetel" type="text" value="'..res[1].officetel..'"><br>'
        sel = sel .. '住宅电话:<input name="hometel" id="hometel" type="text" value="'..res[1].hometel..'"><br>'
        sel = sel .. '手机:<input name="celtel" id="celtel" type="text" value="'..res[1].celtel..'"><br>'
        sel = sel .. '<input name="id" id="id" type="hidden" value="'..res[1].id .. '">'
        return sel..depname 
    else
        return "not found"
    end
end
function _M.my_doaddtel(args)
    for key, val in pairs(args) do
        args[key] = ndk.set_var.set_quote_sql_str(tostring(val))
    end
    local query="insert into person (id,name,namepy,depid,job,hometel,officetel,celtel) values (null,"..args.name ..","..args.namepy..","..args.depselect..","..args.job .. ","..args.hometel..","..args.officetel..","..args.celtel..")"
    local res=dodbquery("tel",query)
    if res then
        ngx.say("添加成功，<a href='/tel/add'>继续添加</a>")
    end
end
function _M.domodtel(args)
    for key, val in pairs(args) do
        args[key] = ndk.set_var.set_quote_sql_str(tostring(val))
    end
    local query="update person set name="..args.name..",namepy="..args.namepy..",depid="..args.depselect..",job="..args.job..",hometel="..args.hometel..",officetel="..args.officetel..",celtel="..args.celtel.." where id="..args.id
    local res=dodbquery("tel",query)
    if res then
        ngx.say("<font color='red'><b>"..args.name.."的资料更新成功</b></font>")
    end
end
function _M.my_dosearch(args)
    local key = "%"..tostring(args.query).."%"
    local key=ndk.set_var.set_quote_sql_str(key)
    local query ="select count(*) as count from tel.department where depname like" ..key
    local rescount = dodbquery("tel",query)
    local depidwhere=''
    if rescount[1].count ~= '0' then
        local query = "select id from tel.department where depname like" ..key
        local depres=dodbquery("tel",query)
        local depid=''
        for i,key in ipairs(depres) do
            if string.len(depid) ~=0 then
                depid=depid ..","..depres[i].id
            else
                depid =depres[i].id
            end
        end
        depidwhere = "or a.depid in ("..depid..")"
    end
    query= "select a.*,b.depname from tel.person as a LEFT JOIN tel.department as b on a.depid=b.id where a.name like "..key .. " or a.hometel like "..key .. "or b.depname like "..key .." or a.officetel like " .. key .." or a.celtel like "..key .."or a.job like " .. key .." or a.namepy = '"..tostring(args.query).."' "..depidwhere
    local res,err=dodbquery("tel",query)
    local t={}
    local rtable=''
    local result=''
    local m=0
    local replace = "$1<b><div class='keywords'>"..args.query.."</div></b>$2"
    local sub = "(.*)"..args.query.."(.*)"
    if res and #res ~= 0 then
        for i,keyv in ipairs(res) do
            m=m+1
            local tdclass='spec'
            local tdclass1=''
            if math.fmod(m,2) == 0 then
                tdclass='specalt'
                tdclass1='alt'
            end

            local name,n,err = ngx.re.sub(res[i].name,sub,replace)

            result = result ..[[<tr>
            <th scope="row" class=]]..tdclass..[[>]]..name..[[</th>]]

            if res[i].depname ~='' then
                result =result .. [[<td class=]]..tdclass1..[[>]]..res[i].depname..[[</td>]]
            else
                result =result .. [[<td class=]]..tdclass1..[[> </td>]]
            end 
            if res[i].officetel and res[i].officetel ~= ''  then
                local officetel,n,err = ngx.re.sub(res[i].officetel,sub,replace)
                result =result.. [[ <td class=]]..tdclass1..[[>]]..officetel..[[</td>]]
            else
                result=result.. [[ <td class=]]..tdclass1..[[></td>]]
            end
            if res[i].hometel and res[i].hometel ~='' then
                local hometel,n,err = ngx.re.sub(res[i].hometel,sub,replace)
                result =result.. [[ <td class=]]..tdclass1..[[>]]..hometel..[[</td>]]
            else
                result = result..[[ <td class=]]..tdclass1..[[>]]..[[</td>]]
            end
            if res[i].celtel and res[i].celtel ~='' then
                local celtel,n,err = ngx.re.sub(res[i].celtel,sub,replace)
                result = result ..[[ <td class=]]..tdclass1..[[>]]..celtel..[[</td>]]
            else
                result =result ..[[ <td class=]]..tdclass1..[[>]]..[[</td>]]
            end
            if res[i].job and res[i].job ~='' then
                local job,n,err = ngx.re.sub(res[i].job,sub,replace)
                result =result .. [[ <td class=]]..tdclass1..[[>]]..job..[[</td>]]
            else
                result =result ..[[ <td class=]]..tdclass1..[[>]]..[[</td>]]
            end
            result = result .."</tr>" 
        end
        rtable=[[
        <table id="mytable" cellspacing="0">  
        <caption> </caption>  
        <tr>  
        <th scope="col">姓名</th>  
        <th scope="col">单位</th>  
        <th scope="col">办公电话</th>  
        <th scope="col">住宅电话</th>  
        <th scope="col">手机</th>  
        <th scope="col">职务</th>  
        </tr> 
        ]]
        return rtable..result.."</table>"
    else
        return "没有结果"

    end
end

return _M
