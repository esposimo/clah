#!/bin/bash


_clah_complete() 
{

    local cur prev words cword
    _init_completion || return

    case "${words[1]}" in
        init)
            COMPREPLY=( $(compgen -W "sc kv all network" -- "$cur") )
            ;;
        destroy)
            COMPREPLY=( $(compgen -W "sc kv all network" -- "$cur") )
            ;;
        sc)
            COMPREPLY=( $(compgen -W "get put rm ls lget" -- "$cur") )
            ;;
        sub)
            COMPREPLY=( $(compgen -W "get add rm ls" -- "$cur") )
            ;;
        *)
            COMPREPLY=( $(compgen -W "init sc destroy status sub tf" -- "$cur") )
            ;;
    esac
}

complete -F _clah_complete clah

