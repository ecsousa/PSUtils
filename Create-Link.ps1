function Create-Link {
    & ('cmd.exe') (('/c', 'mklink') + $args)
}
