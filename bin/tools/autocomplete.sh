#!/bin/bash

_clah_complete() 
{

    local cur prev words cword
    _init_completion || return

    case "${words[1]}" in
        sops)
            COMPREPLY=( $(compgen -W "encrypt decrypt new edit" -- "$cur") )
            ;;
        *)
            COMPREPLY=( $(compgen -W "sops elastic vault users" -- "$cur") )
            ;;
    esac
}

complete -F _clah_complete clah