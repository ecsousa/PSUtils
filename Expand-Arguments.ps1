function Expand-Arguments {
    foreach($arg in @($args)) {
        if($arg.GetType().IsArray) {
            Expand-Arguments @arg
        }
        else {
            $arg
        }
    }

}

