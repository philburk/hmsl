
anew task-rw_shape

: old
	mode_oldfile filemode !
;

v: fileid
v: temp-num

: fwrite.num ( number -- , write a single number )
        temp-num !
        fileid @ temp-num 4 fwrite
        -1 = IF
                abort" Can't write number"
        THEN
;

: fread.num ( -- number )
        fileid @ temp-num 4 fread
        -1 = IF
                abort" Can't read number"
        THEN
        temp-num @
;

: write.header ( shape -- , write limit:, dimension: )
        dup max.elements: [] fwrite.num
        dup dimension: [] fwrite.num
        many: [] fwrite.num
;

: read.header ( shape -- , setup with correct dimentia )
        fread.num fread.num 2 pick new: []
        fread.num swap set.many: []
;

: read.data { shape -- , read the raw data }
        fileid @
        shape data.addr: []
        shape max.elements: [] shape dimension: [] *
        shape width: [] *
        fread
        -1 = IF
                abort" Couldn't read raw data"
        THEN
;

: write.data { shape -- , write all the raw data }
        fileid @
        shape data.addr: []
        shape max.elements: [] shape dimension: [] *
        shape width: [] *
        fwrite
        -1 = IF
                abort" Couldn't write raw data"
        THEN
;

: $write.shape ( shape $filename -- , write shape data )
       new 
		$fopen ?dup 
		IF
                fileid !
                dup write.header
                write.data
				fileid @ fflush
                fileid @ fclose
        ELSE
                abort" !!! Can't open file !!!"
        THEN
;

: $read.shape ( shape $filename -- , read shape data )
      	old 
		$fopen ?dup IF
                fileid !
                dup read.header
                read.data
                fileid @ fclose
        ELSE
                abort" !!! Can't open file !!!"
        THEN
;

: write.shape ( shape <filename> -- )
        fileword $write.shape
;

: read.shape ( shape <filename> -- )
        fileword $read.shape
;
