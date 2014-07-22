function Resolve-VimArgs {

    param($myArgs);

    if($myArgs.GetType().IsArray) {
        foreach($arg in $myArgs) {
            $results = Resolve-VimArgs $arg;
            if($results.GetType().IsArray) {
                foreach($result in $results) {
                    $result;
                }
            }
            else {
                $results
            }
        }
    }
    else {
        $arg;
    }

}
