#!/usr/bin/env python3
"""
lua_obfuscator.py
Simple Lua obfuscator with two modes:
 - storage : convert full source to escaped bytes and wrap in loadstring("...")()
 - roblox  : Roblox-friendly obfuscation (remove comments, minify, basic identifier mangling,
             and encode string literals as string.char(...))

Usage:
    python lua_obfuscator.py input.lua output.lua --mode roblox
    python lua_obfuscator.py input.lua output.lua --mode storage
"""

import re
import sys
import argparse
import random
import string

# ---------- Utilities ----------
def readfile(path):
    with open(path, "r", encoding="utf-8") as f:
        return f.read()

def writefile(path, text):
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)

def rand_ident(n=6):
    return "_" + "".join(random.choice(string.ascii_lowercase) for _ in range(n))

# ---------- Mode: storage (escaped bytes + loadstring) ----------
def obf_storage(src):
    # escape each byte as \ddd (decimal escape) to be safe
    # But to avoid issues with quotes/utf-8 in Python string literal, produce concatenation via string.char with byte codes
    # Simpler: produce string with \DDD escapes and embed in loadstring("...")()
    # We'll produce octal escapes \ddd not always supported; better to use decimal escape like \\###? In Lua, \ddd is decimal.
    # We'll produce numeric escapes using string.char(...) to be safe across interpreters:
    bytes_list = [str(ord(c)) for c in src]
    chunk_size = 200  # string.char accepts many args, but keep modest
    parts = []
    for i in range(0, len(bytes_list), chunk_size):
        part = bytes_list[i:i+chunk_size]
        parts.append("string.char(" + ",".join(part) + ")")
    # join parts with ..
    joined = " .. ".join(parts)
    # final wrapper: loadstring( <joined> )()
    obf = "local _ = " + joined + "\nloadstring(_ )()"
    return obf

# ---------- Mode: roblox (Roblox-friendly) ----------
# Steps:
# 1. extract string literals and replace with placeholders -> encoded by string.char(...)
# 2. remove --comments and --[[ ... ]] block comments
# 3. basic identifier mangling: find locals and function names and rename (simple)
# 4. minify: collapse whitespace where safe
# Note: this is heuristic. Always test output in your environment.

string_pattern = re.compile(r'(\"(\\.|[^\"\\])*\"|\'(\\.|[^\'\\])*\')', re.DOTALL)

def encode_string_literal(s):
    # s includes enclosing quotes; remove them
    quote = s[0]
    content = s[1:-1]
    # Convert to list of ord values
    codes = [str(ord(c)) for c in content]
    return "string.char(" + ",".join(codes) + ")"

def remove_comments(src):
    # Remove multiline comments --[[ ... ]]
    src = re.sub(r'--\[\[(.*?)\]\]', lambda m: "", src, flags=re.DOTALL)
    # Remove single-line comments -- ...
    src = re.sub(r'--[^\n\r]*', "", src)
    return src

def find_local_and_function_names(src):
    # find local var declarations: local a, b = ...
    local_names = set()
    for m in re.finditer(r'\blocal\s+([A-Za-z_][A-Za-z0-9_]*(?:\s*,\s*[A-Za-z_][A-Za-z0-9_]*)*)', src):
        group = m.group(1)
        parts = [p.strip() for p in group.split(",")]
        for p in parts:
            local_names.add(p)
    # find function declarations: function fname(...
    func_names = set()
    for m in re.finditer(r'\bfunction\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(', src):
        func_names.add(m.group(1))
    # find local function: local function fname(...)
    for m in re.finditer(r'\blocal\s+function\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(', src):
        func_names.add(m.group(1))
        local_names.add(m.group(1))
    return local_names, func_names

def mangled_map(names):
    mapping = {}
    for i, n in enumerate(sorted(names)):
        mapping[n] = "_v" + ("%x" % (random.randint(0, 0xFFFF)))  # random hex suffix
    return mapping

def apply_identifier_mangling(src, mapping):
    # Replace whole-word occurrences only
    # To avoid replacing keywords or table lookups, we will replace with regex word boundaries.
    # WARNING: this can still break code in edge cases; test thoroughly.
    def repl(m):
        name = m.group(0)
        return mapping.get(name, name)
    pattern = re.compile(r'\b(' + '|'.join(re.escape(k) for k in mapping.keys()) + r')\b')
    return pattern.sub(repl, src)

def minify_whitespace(src):
    # collapse multiple spaces/newlines into single space, but keep newlines after `;` or not needed.
    # Simpler safe minify: remove leading/trailing whitespace lines, collapse consecutive whitespace to single space
    src = re.sub(r'[ \t]+', ' ', src)
    src = re.sub(r'\r\n', '\n', src)
    src = re.sub(r'\n\s*\n', '\n', src)
    src = re.sub(r'\s*\n\s*', '\n', src)  # normalize newlines
    # convert newlines to spaces except after 'end' or 'then' etc could be risky; keep newlines.
    return src.strip()

def obf_roblox(src):
    # 1) extract strings
    strings = {}
    def store_string(m):
        s = m.group(0)
        key = "__STR_" + str(len(strings))
        strings[key] = s
        return key
    src_no_str = string_pattern.sub(store_string, src)

    # 2) remove comments
    src_no_comments = remove_comments(src_no_str)

    # 3) find locals/functions for mangling
    local_names, func_names = find_local_and_function_names(src_no_comments)
    # do not mangle common keywords or Roblox API names — basic blacklist
    blacklist = set([
        "game","workspace","script","tick","print","wait","task","Vector3","CFrame","pairs","ipairs",
        "string","math","table","require","spawn","coroutine","typeof","Enum","Players","workspace"
    ])
    local_names = {n for n in local_names if n not in blacklist and len(n) > 1}
    func_names = {n for n in func_names if n not in blacklist and len(n) > 1}

    local_map = mangled_map(local_names)
    func_map = mangled_map(func_names)

    # 4) replace identifiers in code
    src_mangled = src_no_comments
    if local_map:
        src_mangled = apply_identifier_mangling(src_mangled, local_map)
    if func_map:
        src_mangled = apply_identifier_mangling(src_mangled, func_map)

    # 5) restore strings, but encode them as string.char(...)
    for key, original in strings.items():
        encoded = encode_string_literal(original)
        src_mangled = src_mangled.replace(key, encoded)

    # 6) minify lightly
    src_min = minify_whitespace(src_mangled)
    return src_min

# ---------- Main ----------
def main():
    parser = argparse.ArgumentParser(description="Simple Lua obfuscator (storage or roblox mode)")
    parser.add_argument("input", help="input Lua file")
    parser.add_argument("output", help="output obfuscated file")
    parser.add_argument("--mode", choices=["storage", "roblox"], default="roblox", help="obfuscation mode")
    args = parser.parse_args()

    src = readfile(args.input)

    if args.mode == "storage":
        obf = obf_storage(src)
        writefile(args.output, obf)
        print("[*] Wrote storage-mode obfuscated file to", args.output)
    else:
        obf = obf_roblox(src)
        writefile(args.output, obf)
        print("[*] Wrote roblox-mode obfuscated file to", args.output)
        print("[*] Reminder: test the output in Roblox Studio before deploying to production.")

if __name__ == "__main__":
    main()
