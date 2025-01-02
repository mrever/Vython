command Ruby normal :call Ruby()<cr>:echo "m-, to execute ruby"<cr>

func! Ruby()

if has('ruby')
nnoremap <silent> <m-,>      mPV"py:py3 voly.output()<cr>:redir @b<cr>:ruby eval(_rubyfiltcode, TOPLEVEL_BINDING)<cr>:redir END<cr>:py3 voly.smartprint(vim.eval("@b"))<cr>`P
inoremap <silent> <m-,> <esc>mPV"py:py3 voly.output()<cr>:redir @b<cr>:ruby eval(_rubyfiltcode, TOPLEVEL_BINDING)<cr>:redir END<cr>:py3 voly.smartprint(vim.eval("@b"))<cr>`Pa
vnoremap <silent> <m-,>       mP"py:py3 voly.output()<cr>:redir @b<cr>:ruby eval(_rubyfiltcode, TOPLEVEL_BINDING)<cr>:redir END<cr>:py3 voly.smartprint(vim.eval("@b"))<cr>`P
 
if has('ruby')
ruby << EORUBY
def _rubyfiltcode
    VIM::evaluate("@p")
end
EORUBY
endif


py3 << EOL
import vim

def _rubyevalhelp(rubystring):
    vim.command('redir @b')
    vim.command(f'ruby ___expreval = eval("{rubystring.replace('\"','\\\"')}")')
    vim.command(f'ruby print(___expreval.class)')
    vim.command('redir END')
    valtype = vim.eval("@b").strip()
    vim.command('redir @b')
    vim.command(f'ruby print(___expreval)')
    vim.command('redir END')
    valstr = vim.eval("@b").strip()
    retval = valstr
    if 'Integer' in valtype:
        retval = int(valstr)
    elif 'Float' in valtype:
        retval = float(valstr)
    return retval

def _rubyeval(expr):
    try:
        _rubyexpr = _rubyevalhelp(expr)
        return _rubyexpr
    except Exception as e:
        return e

if '_blank' not in globals():
    class _blank: pass
    languagemgr = _blank()
    languagemgr.langlist  = []
    languagemgr.langevals = []
    languagemgr.langcompleters = []

languagemgr.langlist.append("ruby")
languagemgr.langevals.append(_rubyeval)

EOL

endif

endfunc




