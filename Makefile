all:
	@echo make watch ?

watch:
	sudo supervisor -w main.rb -x ruby -- ./main.rb tst -o allow_other
