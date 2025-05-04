#!/bin/bash


_clah_complete() 
{

    local cur prev words cword
    _init_completion || return

    case "${words[1]}" in
        init)
            COMPREPLY=( $(compgen -W "" -- "$cur") )
            ;;
        destroy)
            COMPREPLY=( $(compgen -W "" -- "$cur") )
            ;;
        sc)
            COMPREPLY=( $(compgen -W "get put rm ls" -- "$cur") )
            ;;
        *)
            COMPREPLY=( $(compgen -W "init sc destroy" -- "$cur") )
            ;;
    esac
}

complete -F _clah_complete clah

