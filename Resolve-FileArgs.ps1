function Resolve-FileArgs {

    param($myArgs);

    if($myArgs) {

        if($myArgs.GetType().IsArray) {
            foreach($arg in $myArgs) {
                $results = Resolve-FileArgs $arg;
                if($results.GetType().IsArray) {
                    foreach($result in $results) {
                        Resolve-PSDrive $result;
                    }
                }
                else {
                    Resolve-PSDrive $results
                }
            }
        }
        else {
            Resolve-PSDrive $arg;
        }
    }

}
