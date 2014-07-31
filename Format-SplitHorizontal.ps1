function Format-SplitHorizontal {
    param([int] $percentage);

    if($percentage) {
        "-new_console:s${percentage}H";
    }
    else {
        "-new_console:sH";
    }
}
