-- // created by tryhazard (tryhazard#9484, https://github.com/tryhazard)

shared.type = "getgc";
local storage = getgenv()[shared.type]();
do
	local f = function(i, v) getgenv()[i] = v; end;
	f("getupvalues", debug.getupvalues or getupvalues or getupvals);
	f("getconstants", debug.getconstants or getconstants or getconsts);
	f("islclosure", islclosure or isluaclosure or is_l_closure);
end;

local scripts = {};
local unknown_names = 0;
local function insert(func)
	local script_name = getfenv(func).name or ("Unknown_" .. unknown_names + 1);
	if script_name == "Unknown_" .. (unknown_names + 1) then unknown_names = unknown_names + 1; end; 
	if scripts[script_name] then return; end;
	scripts[script_name] = {Upvalues = getupvalues(func), Constants = getconstants(func)};
end;

for i, v in pairs(storage) do
	if typeof(v) == "function" and islclosure(v) then
		insert(v);
	end;
end;

for i, v in pairs(scripts) do
	local built = "Upvalues = {\n";
	for index, upvalue in pairs(v.Upvalues) do
		built = built .. "\t" .. tostring(index) .. "\t" .. tostring(upvalue) .. (v.Upvalues[index + 1] ~= nil and ";\n" or ";");
	end;
	built = built .. "\n};";
	if #v.Constants > 0 then
		built = built .. "\nConstants = {\n";
	end;
	for index, constant in pairs(v.Constants) do
		built = built .. "\t" .. tostring(index) .. "\t" .. tostring(constant) .. (v.Constants[index + 1] ~= nil and ";\n" or ";");
	end;
	if #v.Constants > 0 then
		built = built .. "\n};";
	end
	writefile(i .. ".lua", built);
end;
