function Add-Link {
    & ('cmd.exe') (('/c', 'mklink') + $args)
}
