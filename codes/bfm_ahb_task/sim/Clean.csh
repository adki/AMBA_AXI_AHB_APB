#!/bin/csh -f

set DIRS="modelsim isim"

foreach F ( $DIRS )
    if ( -e $F/Clean.csh ) then
       ( cd $F; ./Clean.csh )
    endif
end
