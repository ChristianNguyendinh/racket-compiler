

(let ([s (string #\y #\e #\r #\i #\n)])
	(cons s (substring (apply string (string->list (string-append " marry" " me" " please"))) 0 10)))