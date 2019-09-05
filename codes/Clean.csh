#!/bin/csh -f

foreach F ( * )
    if ( -d $F ) then
    if ( -e $F/Clean.csh ) then
       ( cd $F; ./Clean.csh )
    endif
    endif
end
