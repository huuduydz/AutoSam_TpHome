import re, sys

def minify_lua(code: str) -> str:
    # Xóa comment 1 dòng -- ...
    code = re.sub(r'--[^\n]*', '', code)
    # Xóa comment nhiều dòng --[[ ... ]]
    code = re.sub(r'--\[\[.*?\]\]', '', code, flags=re.S)
    # Xóa dòng trống và khoảng trắng dư
    code = re.sub(r'\s+', ' ', code)
    return code.strip()

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python lua_minify.py input.lua output.lua")
        sys.exit(1)
    inp, outp = sys.argv[1], sys.argv[2]
    with open(inp, "r", encoding="utf8") as f:
        code = f.read()
    with open(outp, "w", encoding="utf8") as f:
        f.write(minify_lua(code))
    print(f"✅ Minified saved to {outp}")
