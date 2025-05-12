#!/bin/bash

_clah_complete() 
{

    local cur prev words cword
    _init_completion || return

    case "${words[1]}" in
        config)
            COMPREPLY=( $(compgen -W "get put ls rm lget help" -- "$cur") )
            ;;
        init)
            COMPREPLY=( $(compgen -W "sc network vault all" -- "$cur") )
            ;;
        destroy)
            COMPREPLY=( $(compgen -W "sc network vault all" -- "$cur") )
            ;;
        sops)
            COMPREPLY=( $(compgen -W "encrypt decrypt new edit" -- "$cur") )
            ;;
        *)
            COMPREPLY=( $(compgen -W "sops elastic vault users sc config init destroy" -- "$cur") )
            ;;
    esac
}

complete -F _clah_complete clah