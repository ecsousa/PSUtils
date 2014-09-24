function Format-SplitVertical {
    param([int] $percentage);

    if($percentage) {
        "-new_console:s${percentage}V";
    }
    else {
        "-new_console:sV";
    }
}
