-include ../etc/Makefile

docs/%.html : %.lua $(which pycco)
	mkdir -p docs
	pycco -d docs $^
	echo "p {text-align: right; }" >> docs/pycco.css
