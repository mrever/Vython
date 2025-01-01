command! Coconut normal :call Coconut()<cr>
command! Coconutoff normal :py3 _coconut_On_ = False<cr>

func! Coconut()
py3 << EOL
_coconut_On_ = True
try:
    import sys as _coconut_sys
    from coconut.__coconut__ import *
    from coconut.__coconut__ import _coconut_tail_call, _coconut_tco, _coconut_call_set_names, _coconut_handle_cls_kwargs, _coconut_handle_cls_stargs, _coconut, _coconut_MatchError,  _coconut_base_compose, _coconut_forward_compose, _coconut_back_compose, _coconut_forward_star_compose, _coconut_back_star_compose, _coconut_forward_dubstar_compose, _coconut_back_dubstar_compose, _coconut_pipe, _coconut_star_pipe, _coconut_dubstar_pipe, _coconut_back_pipe, _coconut_back_star_pipe, _coconut_back_dubstar_pipe, _coconut_none_pipe, _coconut_none_star_pipe, _coconut_none_dubstar_pipe, _coconut_bool_and, _coconut_bool_or, _coconut_none_coalesce, _coconut_minus, _coconut_map, _coconut_partial, _coconut_get_function_match_error, _coconut_base_pattern_func, _coconut_addpattern, _coconut_sentinel, _coconut_assert, _coconut_mark_as_match, _coconut_reiterable, _coconut_self_match_types, _coconut_dict_merge, _coconut_exec
    from coconut.convenience import parse as _cocoparsetemp
    def _cocoparse(cocostr):
        cocolines = cocostr.split('\n')
        for idx, line in enumerate(cocolines):
            if 'import ' in line:
                cocolines[idx] += ' # noqa '
        cocolinesout = _cocoparsetemp('\n'.join(cocolines)).split('\n')[6:]
        return '\n'.join(cocolinesout)
    if '_blank' not in globals():
        class _blank: pass
        languagemgr = _blank()
        languagemgr.langlist  = []
        languagemgr.langevals = []
        languagemgr.langcompleters = []
    languagemgr.langlist.append("coconut")

    def filtcode():
        global _coconut_On_
        voly.removeindent()
        code = [q for q in vim.eval("@p").split('\n') if q and len(q)>0]
        code = [q for q in code if q and len(q.strip())>0 and q.strip()[0]!='!']
        #try:
        if _coconut_On_:
            parsedout = _cocoparse('\n'.join(code))
            if _sage_On_:
                parsedout = sageparse(parsedout)
        else:
            parsedout = ('\n'.join(code))
        #except:
            #parsedout = ('\n'.join(code))
        return parsedout
except:
    _cocoparse = lambda x: x
    print('coconut not installed')

EOL
endfunc
