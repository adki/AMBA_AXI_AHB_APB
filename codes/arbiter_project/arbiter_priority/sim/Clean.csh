#!/bin/csh -f

foreach D ( * )
        if ( -d "$D" && ! -l "$D" ) then
                if ( -e $D/Clean.csh ) then
                        (cd $D; ./Clean.csh )
                endif
        endif
end
