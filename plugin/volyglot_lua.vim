command Lua normal :call Lua()<cr>:echo "m-/ to execute lua"<cr>

func! Lua()

if has('lua') || has('nvim')
nnoremap <silent> <m-/>      mPV"py:py3 voly.output()<cr>:redir @b<cr>:lua load(_luafiltcode())()<cr>:redir END<cr>:py3 voly.smartprint(vim.eval("@b"))<cr>`P
inoremap <silent> <m-/> <esc>mPV"py:py3 voly.output()<cr>:redir @b<cr>:lua load(_luafiltcode())()<cr>:redir END<cr>:py3 voly.smartprint(vim.eval("@b"))<cr>`Pa
vnoremap <silent> <m-/>       mP"py:py3 voly.output()<cr>:redir @b<cr>:lua load(_luafiltcode())()<cr>:redir END<cr>:py3 voly.smartprint(vim.eval("@b"))<cr>`P
 
if has('lua')
lua << EOLUA
function _luafiltcode()
    return vim.eval("@p")
end
EOLUA
endif

if has('nvim')
lua << EOLUA
function _luafiltcode()
    return vim.fn.getreg("p")
end
EOLUA
endif

py3 << EOL
import vim

def _luaevalhelp(luastring):
    vim.command('redir @b')
    vim.command(f'lua print(type({luastring}))')
    vim.command('redir END')
    valtype = vim.eval("@b").strip()
    vim.command('redir @b')
    vim.command(f'lua print({luastring})')
    vim.command('redir END')
    valstr = vim.eval("@b").strip()
    retval = valstr
    if valtype == 'number':
        if '.' in valstr:
            retval = float(valstr)
        else:
            retval = int(valstr)
    if valtype == 'boolean':
        if valstr.lower() == 'true':
            retval = True
        else:
            retval = False
    if valtype == 'nil':
        retval = None
    return retval
    #return valstr + ' ' + valtype



def _luaeval(expr):
    try:
        _luaeexpr = _luaevalhelp(expr)
        return _luaeexpr
    except Exception as e:
        return e

if '_blank' not in globals():
    class _blank: pass
    languagemgr = _blank()
    languagemgr.langlist  = []
    languagemgr.langevals = []
    languagemgr.langcompleters = []

languagemgr.langlist.append("lua")
languagemgr.langevals.append(_luaeval)

EOL

endif

endfunc




